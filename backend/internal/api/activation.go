package api

import (
	"crypto/rand"
	"errors"
	"math/big"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/nurpay/backend/internal/store"
)

// Код печатается на карте и вводится руками, поэтому он цифровой и
// короткий: 12 цифр, как на экране ввода в приложении.
const activationCodeDigits = 12

// Сколько раз пробовать другой код при совпадении с существующим.
// При 10^12 вариантов это чистая формальность.
const activationCodeAttempts = 5

// errCodeUnavailable — код не существует или уже погашен. Наружу оба
// случая выглядят одинаково: подбирать чужие коды по ответу нельзя.
var errCodeUnavailable = errors.New("activation code unavailable")

type createActivationCodeRequest struct {
	// Теңңе, целое.
	Amount int64 `json:"amount"`

	// Через какого мерчанта продаётся код.
	MerchantID string `json:"merchant_id"`
}

type activationCodeResponse struct {
	ID         int64     `json:"id"`
	Code       string    `json:"code"`
	Amount     int64     `json:"amount"`
	MerchantID uuid.UUID `json:"merchant_id"`
	Status     string    `json:"status"`
}

type activateRequest struct {
	Code string `json:"code"`
}

// createActivationCode выпускает код. Проводок при этом не появляется:
// код — только обещание денег, пока его не активировали.
func (s *Server) createActivationCode(c *gin.Context) {
	ctx := c.Request.Context()

	var req createActivationCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if req.Amount <= 0 {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "amount must be positive")
		return
	}

	merchantID, err := uuid.Parse(req.MerchantID)
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "merchant_id must be a uuid")
		return
	}

	merchant, err := s.q.GetUserByID(ctx, merchantID)
	if errors.Is(err, pgx.ErrNoRows) {
		Fail(c, http.StatusNotFound, CodeNotFound, "merchant not found")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}
	if merchant.Type != store.UserTypeMerchant {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "user is not a merchant")
		return
	}

	code, err := s.issueActivationCode(c, req.Amount, merchantID)
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusCreated, activationCodeResponse{
		ID:         code.ID,
		Code:       code.Code,
		Amount:     code.Amount,
		MerchantID: code.MerchantID,
		Status:     string(code.Status),
	})
}

// issueActivationCode подбирает свободный код.
func (s *Server) issueActivationCode(
	c *gin.Context,
	amount int64,
	merchantID uuid.UUID,
) (store.ActivationCode, error) {
	for attempt := 0; attempt < activationCodeAttempts; attempt++ {
		value, err := randomDigits(activationCodeDigits)
		if err != nil {
			return store.ActivationCode{}, err
		}

		code, err := s.q.CreateActivationCode(
			c.Request.Context(),
			store.CreateActivationCodeParams{
				Code:       value,
				Amount:     amount,
				MerchantID: merchantID,
			},
		)
		if err == nil {
			return code, nil
		}

		// 23505 — unique_violation: код уже занят, берём следующий.
		var pgErr *pgconn.PgError
		if !errors.As(err, &pgErr) || pgErr.Code != "23505" {
			return store.ActivationCode{}, err
		}
	}

	return store.ActivationCode{}, errors.New("could not generate a free activation code")
}

// activate — пополнение счёта кодом.
func (s *Server) activate(c *gin.Context) {
	user := CurrentUser(c)
	ctx := c.Request.Context()

	var req activateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if req.Code == "" {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "code is required")
		return
	}

	var mainEntryID int64
	err := store.InTx(ctx, s.pool, func(q *store.Queries) error {
		// Комиссию платит юзер, то есть это списание с него — блокируем
		// его строку. issuance не блокируем: он расходный по замыслу,
		// баланс ему не проверяется, а блокировка на нём выстроила бы
		// все активации в системе в одну очередь.
		if _, err := q.LockUserForUpdate(ctx, user.ID); err != nil {
			return err
		}

		code, err := q.RedeemActivationCode(ctx, store.RedeemActivationCodeParams{
			Code:        req.Code,
			ActivatedBy: &user.ID,
		})
		if errors.Is(err, pgx.ErrNoRows) {
			return errCodeUnavailable
		}
		if err != nil {
			return err
		}

		main, err := q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: store.IssuanceUserID,
			ToUserID:   user.ID,
			Amount:     code.Amount,
			Type:       store.LedgerEntryTypeActivation,
		})
		if err != nil {
			return err
		}
		mainEntryID = main.ID

		fee := feeFor(code.Amount, s.cfg.ActivationFeePercent)
		if fee == 0 {
			// Проводка на ноль запрещена схемой, а при сумме меньше
			// 100 теңңе комиссия обнуляется формулой.
			return nil
		}

		_, err = q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: user.ID,
			ToUserID:   store.FeesUserID,
			Amount:     fee,
			Type:       store.LedgerEntryTypeFee,
			ParentID:   &main.ID,
		})
		return err
	})

	if errors.Is(err, errCodeUnavailable) {
		Fail(c, http.StatusConflict, CodeCodeAlreadyUsed,
			"activation code does not exist or is already used")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}

	s.respondWithOperation(c, user.ID, mainEntryID)
}

// respondWithOperation отдаёт операцию тем же запросом, что и история:
// клиент получает ровно то, что потом увидит в списке.
func (s *Server) respondWithOperation(
	c *gin.Context,
	viewerID uuid.UUID,
	operationID int64,
) {
	rows, err := s.q.GetOperationEntries(
		c.Request.Context(),
		store.GetOperationEntriesParams{FromUserID: viewerID, ID: operationID},
	)
	if err != nil {
		FailInternal(c, err)
		return
	}

	entries := make([]entryResponse, 0, len(rows))
	for _, row := range rows {
		entries = append(entries, newEntryResponse(viewerID, row.Ledger, counterparty{
			UserID:      row.CounterpartyID,
			UserType:    string(row.CounterpartyType),
			DisplayName: row.CounterpartyDisplayName,
			Phone:       row.CounterpartyPhone,
		}))
	}

	c.JSON(http.StatusCreated, gin.H{"entries": entries})
}

// randomDigits — криптостойкая строка из цифр.
func randomDigits(n int) (string, error) {
	digits := make([]byte, n)
	for i := range digits {
		value, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", err
		}
		digits[i] = byte('0' + value.Int64())
	}
	return string(digits), nil
}

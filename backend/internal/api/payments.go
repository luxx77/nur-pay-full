package api

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/nurpay/backend/internal/store"
)

// Сколько живёт платёжный QR. Время берётся из самого nonce (uuid v7),
// допуска на рассинхрон часов нет — так решено в ТЗ.
const paymentQRLifetime = 30 * time.Second

// errNonceUsed — по этому QR уже платили. Ловится на уникальном индексе,
// а не проверкой заранее: только так между проверкой и вставкой не
// проскочит второе списание.
var errNonceUsed = errors.New("nonce already used")

type merchantPaymentRequest struct {
	// Всё, кроме amount, приходит из QR как есть.
	UserID    string `json:"user_id"`
	MaxAmount int64  `json:"max_amount"`
	Nonce     string `json:"nonce"`
	Hash      string `json:"hash"`

	// Сколько кассир пробил. Не больше max_amount.
	Amount int64 `json:"amount"`
}

// createMerchantPayment — мерчант отсканировал QR юзера и списывает сумму.
func (s *Server) createMerchantPayment(c *gin.Context) {
	merchant := CurrentUser(c)
	ctx := c.Request.Context()

	var req merchantPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if req.Amount <= 0 {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "amount must be positive")
		return
	}
	if req.MaxAmount <= 0 {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "max_amount must be positive")
		return
	}

	payerID, err := uuid.Parse(req.UserID)
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "user_id must be a uuid")
		return
	}

	nonce, err := uuid.Parse(req.Nonce)
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "nonce must be a uuid")
		return
	}

	payer, err := s.q.GetUserByID(ctx, payerID)
	if errors.Is(err, pgx.ErrNoRows) {
		Fail(c, http.StatusNotFound, CodeNotFound, "payer not found")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}

	// Секрет системных счетов лежит открытым текстом в сид-миграции,
	// так что подпись за них подделал бы кто угодно.
	if payer.Type == store.UserTypeSystem {
		Fail(c, http.StatusBadRequest, CodeBadRequest,
			"cannot charge a system account")
		return
	}
	if payer.ID == merchant.ID {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "cannot charge yourself")
		return
	}

	expected := paymentSignature(payer.PaymentSecret, payer.ID, req.MaxAmount, nonce)
	if !hmac.Equal([]byte(strings.ToLower(req.Hash)), []byte(expected)) {
		Fail(c, http.StatusBadRequest, CodeInvalidSignature, "signature does not match")
		return
	}

	if err := checkQRFreshness(nonce); err != nil {
		Fail(c, http.StatusConflict, CodeQRExpired, err.Error())
		return
	}

	if req.Amount > req.MaxAmount {
		Fail(c, http.StatusConflict, CodeAmountExceedsMax,
			"amount is greater than the limit in the qr code")
		return
	}

	var mainEntryID int64
	err = store.InTx(ctx, s.pool, func(q *store.Queries) error {
		// Блокируем того, чей баланс проверяем. Мерчанта не блокируем:
		// его комиссия оплачивается тем же платежом, что пришёл выше по
		// этой же транзакции, и в минус увести его не может.
		if _, err := q.LockUserForUpdate(ctx, payer.ID); err != nil {
			return err
		}

		balance, err := q.GetBalance(ctx, payer.ID)
		if err != nil {
			return err
		}
		if balance < req.Amount {
			return errInsufficientFunds
		}

		main, err := q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: payer.ID,
			ToUserID:   merchant.ID,
			Amount:     req.Amount,
			Type:       store.LedgerEntryTypeMerchantPayment,
			Nonce:      &nonce,
		})
		if isNonceConflict(err) {
			return errNonceUsed
		}
		if err != nil {
			return err
		}
		mainEntryID = main.ID

		fee := feeFor(req.Amount, s.cfg.MerchantPaymentFeePercent)
		if fee == 0 {
			return nil
		}

		_, err = q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: merchant.ID,
			ToUserID:   store.FeesUserID,
			Amount:     fee,
			Type:       store.LedgerEntryTypeFee,
			ParentID:   &main.ID,
		})
		return err
	})

	switch {
	case errors.Is(err, errNonceUsed):
		Fail(c, http.StatusConflict, CodeNonceUsed,
			"this qr code has already been paid")
		return
	case errors.Is(err, errInsufficientFunds):
		Fail(c, http.StatusConflict, CodeInsufficientFunds, "insufficient funds")
		return
	case err != nil:
		FailInternal(c, err)
		return
	}

	s.respondWithOperation(c, merchant.ID, mainEntryID)
}

// paymentSignature повторяет подпись, которую считает приложение юзера.
//
// Подписываемая строка канонична: «<user_id>.<max_amount>.<nonce>», UUID
// в нижнем регистре, сумма — целое в теңңе. Любое расхождение с клиентом
// ломает оплату, поэтому формат зафиксирован здесь одним местом.
func paymentSignature(
	secret string,
	userID uuid.UUID,
	maxAmount int64,
	nonce uuid.UUID,
) string {
	mac := hmac.New(sha256.New, []byte(secret))
	fmt.Fprintf(mac, "%s.%d.%s", userID, maxAmount, nonce)
	return hex.EncodeToString(mac.Sum(nil))
}

// checkQRFreshness читает время генерации из uuid v7.
func checkQRFreshness(nonce uuid.UUID) error {
	if nonce.Version() != 7 {
		return errors.New("nonce must be a uuid v7")
	}

	sec, nsec := nonce.Time().UnixTime()
	age := time.Since(time.Unix(sec, nsec))

	// Отрицательный возраст — часы телефона убежали вперёд. Допуска нет,
	// такой код считаем негодным, а не «ещё не наступившим».
	if age < 0 || age > paymentQRLifetime {
		return errors.New("qr code is older than 30 seconds")
	}
	return nil
}

// isNonceConflict распознаёт нарушение уникальности именно по nonce.
func isNonceConflict(err error) bool {
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) || pgErr.Code != "23505" {
		return false
	}
	return strings.Contains(pgErr.ConstraintName, "nonce")
}

// requireType пускает дальше только выбранную роль.
func requireType(expected store.UserType) gin.HandlerFunc {
	return func(c *gin.Context) {
		if CurrentUser(c).Type != expected {
			Fail(c, http.StatusForbidden, CodeForbidden,
				"this endpoint is for "+string(expected)+" accounts only")
			return
		}
		c.Next()
	}
}

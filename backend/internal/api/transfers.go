package api

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/nurpay/backend/internal/store"
)

// errInsufficientFunds выносит отказ по балансу из транзакции наружу,
// чтобы обработчик перевёл его в код ответа.
var errInsufficientFunds = errors.New("insufficient funds")

type transferRequest struct {
	// Статичный QR получателя, который отсканировал отправитель.
	RecipientQRUUID string `json:"recipient_qr_uuid"`

	// Теңңе, целое.
	Amount int64 `json:"amount"`
}

// createTransfer — перевод по постоянному QR или из контактов.
//
// Юзеру: комиссии нет, списываем ровно столько, сколько получает вторая
// сторона. Мерчанту: это оплата в его пользу, поэтому проводка идёт как
// merchant_payment, а комиссию платит он (как при оплате по платёжному QR);
// отправитель всё равно платит ровно req.Amount.
func (s *Server) createTransfer(c *gin.Context) {
	sender := CurrentUser(c)
	ctx := c.Request.Context()

	var req transferRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if req.Amount <= 0 {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "amount must be positive")
		return
	}

	qrUUID, err := uuid.Parse(req.RecipientQRUUID)
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest,
			"recipient_qr_uuid must be a uuid")
		return
	}

	recipient, err := s.q.GetUserByPublicQRUUID(ctx, qrUUID)
	if errors.Is(err, pgx.ErrNoRows) {
		Fail(c, http.StatusNotFound, CodeNotFound, "recipient not found")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}

	if recipient.ID == sender.ID {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "cannot transfer to yourself")
		return
	}
	// Системные счета обслуживают эмиссию и комиссии; переводить на них
	// снаружи нечего.
	if recipient.Type == store.UserTypeSystem {
		Fail(c, http.StatusBadRequest, CodeBadRequest,
			"cannot transfer to a system account")
		return
	}

	entryType := store.LedgerEntryTypeP2p
	if recipient.Type == store.UserTypeMerchant {
		entryType = store.LedgerEntryTypeMerchantPayment
	}

	var entry store.Ledger
	err = store.InTx(ctx, s.pool, func(q *store.Queries) error {
		// Порядок важен: сначала блокировка плательщика, потом чтение
		// баланса. Иначе параллельный перевод успеет списать между
		// проверкой и записью.
		if _, err := q.LockUserForUpdate(ctx, sender.ID); err != nil {
			return err
		}

		balance, err := q.GetBalance(ctx, sender.ID)
		if err != nil {
			return err
		}
		if balance < req.Amount {
			return errInsufficientFunds
		}

		entry, err = q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: sender.ID,
			ToUserID:   recipient.ID,
			Amount:     req.Amount,
			Type:       entryType,
		})
		if err != nil {
			return err
		}

		if recipient.Type != store.UserTypeMerchant {
			return nil
		}
		fee := feeFor(req.Amount, s.cfg.MerchantPaymentFeePercent)
		if fee == 0 {
			return nil
		}
		_, err = q.InsertLedgerEntry(ctx, store.InsertLedgerEntryParams{
			FromUserID: recipient.ID,
			ToUserID:   store.FeesUserID,
			Amount:     fee,
			Type:       store.LedgerEntryTypeFee,
			ParentID:   &entry.ID,
		})
		return err
	})

	if errors.Is(err, errInsufficientFunds) {
		Fail(c, http.StatusConflict, CodeInsufficientFunds, "insufficient funds")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"entries": []entryResponse{
			newEntryResponse(sender.ID, entry, counterparty{
				UserID:      recipient.ID,
				UserType:    string(recipient.Type),
				DisplayName: recipient.DisplayName,
				Phone:       recipient.Phone,
			}),
		},
	})
}

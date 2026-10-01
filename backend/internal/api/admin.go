package api

import (
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/nurpay/backend/internal/store"
)

// adminUserResponse — строка списка/карточки пользователя в админке.
// В отличие от publicUserResponse отдаёт баланс: это вид для сотрудника,
// а не для другого пользователя приложения.
type adminUserResponse struct {
	UserID      uuid.UUID `json:"user_id"`
	UserType    string    `json:"user_type"`
	DisplayName *string   `json:"display_name"`
	Phone       *string   `json:"phone"`
	Balance     int64     `json:"balance"`
	CreatedAt   time.Time `json:"created_at"`
}

// listAdminUsers — список пользователей и мерчантов с балансом, с поиском
// по телефону/имени и фильтром по типу.
func (s *Server) listAdminUsers(c *gin.Context) {
	ctx := c.Request.Context()

	limit, offset, ok := paging(c)
	if !ok {
		return
	}

	var userType *store.UserType
	if raw := c.Query("type"); raw != "" {
		t := store.UserType(raw)
		if t != store.UserTypeUser && t != store.UserTypeMerchant {
			Fail(c, http.StatusBadRequest, CodeBadRequest, "type must be user or merchant")
			return
		}
		userType = &t
	}

	var search *string
	if raw := c.Query("search"); raw != "" {
		search = &raw
	}

	users, err := s.q.ListUsers(ctx, store.ListUsersParams{
		UserType: userType,
		Search:   search,
		Limit:    limit,
		Offset:   offset,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	out := make([]adminUserResponse, len(users))
	for i, u := range users {
		balance, err := s.q.GetBalance(ctx, u.ID)
		if err != nil {
			FailInternal(c, err)
			return
		}
		out[i] = newAdminUserResponse(u, balance)
	}

	c.JSON(http.StatusOK, gin.H{"users": out})
}

func newAdminUserResponse(u store.User, balance int64) adminUserResponse {
	return adminUserResponse{
		UserID:      u.ID,
		UserType:    string(u.Type),
		DisplayName: u.DisplayName,
		Phone:       u.Phone,
		Balance:     balance,
		CreatedAt:   u.CreatedAt,
	}
}

// getAdminUserByID достаёт пользователя по :id из пути, с единым ответом
// об ошибке для невалидного uuid и отсутствующей записи.
func (s *Server) getAdminUserByID(c *gin.Context) (store.User, bool) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "id must be a uuid")
		return store.User{}, false
	}

	user, err := s.q.GetUserByID(c.Request.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) {
		Fail(c, http.StatusNotFound, CodeNotFound, "user not found")
		return store.User{}, false
	}
	if err != nil {
		FailInternal(c, err)
		return store.User{}, false
	}
	return user, true
}

// getAdminUser — карточка пользователя с балансом.
func (s *Server) getAdminUser(c *gin.Context) {
	user, ok := s.getAdminUserByID(c)
	if !ok {
		return
	}

	balance, err := s.q.GetBalance(c.Request.Context(), user.ID)
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusOK, newAdminUserResponse(user, balance))
}

// listAdminUserOperations — история проводок пользователя, видом из
// админки (та же проекция, что и в приложении).
func (s *Server) listAdminUserOperations(c *gin.Context) {
	user, ok := s.getAdminUserByID(c)
	if !ok {
		return
	}

	// from/to — необязательное окно по времени (RFC3339), для помесячного
	// вида на странице мерчанта. Без них — обычная пагинация.
	fromRaw, toRaw := c.Query("from"), c.Query("to")
	if fromRaw != "" || toRaw != "" {
		from, err := time.Parse(time.RFC3339, fromRaw)
		if err != nil {
			Fail(c, http.StatusBadRequest, CodeBadRequest, "from must be RFC3339")
			return
		}
		to, err := time.Parse(time.RFC3339, toRaw)
		if err != nil {
			Fail(c, http.StatusBadRequest, CodeBadRequest, "to must be RFC3339")
			return
		}

		rows, err := s.q.ListUserEntriesInRange(c.Request.Context(), store.ListUserEntriesInRangeParams{
			UserID: user.ID,
			From:   from,
			To:     to,
		})
		if err != nil {
			FailInternal(c, err)
			return
		}

		entries := make([]entryResponse, 0, len(rows))
		for _, row := range rows {
			entries = append(entries, newEntryResponse(user.ID, row.Ledger, counterparty{
				UserID:      row.CounterpartyID,
				UserType:    string(row.CounterpartyType),
				DisplayName: row.CounterpartyDisplayName,
				Phone:       row.CounterpartyPhone,
			}))
		}
		c.JSON(http.StatusOK, gin.H{"entries": entries})
		return
	}

	limit, offset, ok := paging(c)
	if !ok {
		return
	}

	rows, err := s.q.ListUserEntries(c.Request.Context(), store.ListUserEntriesParams{
		FromUserID: user.ID,
		Limit:      limit,
		Offset:     offset,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	entries := make([]entryResponse, 0, len(rows))
	for _, row := range rows {
		entries = append(entries, newEntryResponse(user.ID, row.Ledger, counterparty{
			UserID:      row.CounterpartyID,
			UserType:    string(row.CounterpartyType),
			DisplayName: row.CounterpartyDisplayName,
			Phone:       row.CounterpartyPhone,
		}))
	}

	c.JSON(http.StatusOK, gin.H{"entries": entries})
}

type topupRequest struct {
	// Теңңе, целое. Комиссия не берётся: это ручное пополнение сотрудником.
	Amount int64 `json:"amount"`
}

// topupUser — ручное пополнение счёта сотрудником админки. Деньги идут
// с эмиссионного счёта, как и при активации кода, но без комиссии.
func (s *Server) topupUser(c *gin.Context) {
	user, ok := s.getAdminUserByID(c)
	if !ok {
		return
	}
	if user.Type == store.UserTypeSystem {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "cannot top up a system account")
		return
	}

	var req topupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if req.Amount <= 0 {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "amount must be positive")
		return
	}

	entry, err := s.q.InsertLedgerEntry(c.Request.Context(), store.InsertLedgerEntryParams{
		FromUserID: store.IssuanceUserID,
		ToUserID:   user.ID,
		Amount:     req.Amount,
		Type:       store.LedgerEntryTypeAdminTopup,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	balance, err := s.q.GetBalance(c.Request.Context(), user.ID)
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"entry":   newEntryResponse(user.ID, entry, counterparty{UserID: store.IssuanceUserID, UserType: string(store.UserTypeSystem)}),
		"balance": balance,
	})
}

// feeEntryResponse — проводка комиссии вместе с тем, кто её заплатил:
// в списке комиссий это не "собеседник", а сам предмет интереса.
type feeEntryResponse struct {
	ID        int64        `json:"id"`
	Amount    int64        `json:"amount"`
	ParentID  *int64       `json:"parent_id"`
	Payer     counterparty `json:"payer"`
	CreatedAt time.Time    `json:"created_at"`
}

// getFeesBalance — сколько всего накоплено на счёте комиссий.
func (s *Server) getFeesBalance(c *gin.Context) {
	balance, err := s.q.GetBalance(c.Request.Context(), store.FeesUserID)
	if err != nil {
		FailInternal(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"balance": balance})
}

// listAdminFeeOperations — лента всех проводок комиссий, свежие сверху.
func (s *Server) listAdminFeeOperations(c *gin.Context) {
	limit, offset, ok := paging(c)
	if !ok {
		return
	}

	rows, err := s.q.ListFeeEntries(c.Request.Context(), store.ListFeeEntriesParams{
		Limit:  limit,
		Offset: offset,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	entries := make([]feeEntryResponse, 0, len(rows))
	for _, row := range rows {
		entries = append(entries, feeEntryResponse{
			ID:       row.Ledger.ID,
			Amount:   row.Ledger.Amount,
			ParentID: row.Ledger.ParentID,
			Payer: counterparty{
				UserID:      row.PayerID,
				UserType:    string(row.PayerType),
				DisplayName: row.PayerDisplayName,
				Phone:       row.PayerPhone,
			},
			CreatedAt: row.Ledger.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{"entries": entries})
}

// activationCodeListResponse — код в списке админки, вместе с мерчантом,
// через которого он продан.
type activationCodeListResponse struct {
	ID          int64        `json:"id"`
	Code        string       `json:"code"`
	Amount      int64        `json:"amount"`
	Status      string       `json:"status"`
	Merchant    counterparty `json:"merchant"`
	CreatedAt   time.Time    `json:"created_at"`
	ActivatedAt *time.Time   `json:"activated_at"`
}

// listAdminActivationCodes — коды из базы, свежие сверху, с фильтром по
// статусу. В отличие от ленты «созданных в этой сессии» переживает
// обновление страницы: источник правды — таблица, а не память фронта.
func (s *Server) listAdminActivationCodes(c *gin.Context) {
	limit, offset, ok := paging(c)
	if !ok {
		return
	}

	var status *store.ActivationCodeStatus
	if raw := c.Query("status"); raw != "" {
		st := store.ActivationCodeStatus(raw)
		if st != store.ActivationCodeStatusActive && st != store.ActivationCodeStatusUsed {
			Fail(c, http.StatusBadRequest, CodeBadRequest, "status must be active or used")
			return
		}
		status = &st
	}

	rows, err := s.q.ListActivationCodes(c.Request.Context(), store.ListActivationCodesParams{
		Status: status,
		Limit:  limit,
		Offset: offset,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	out := make([]activationCodeListResponse, len(rows))
	for i, row := range rows {
		out[i] = activationCodeListResponse{
			ID:     row.ID,
			Code:   row.Code,
			Amount: row.Amount,
			Status: string(row.Status),
			Merchant: counterparty{
				UserID:      row.MerchantID,
				UserType:    string(store.UserTypeMerchant),
				DisplayName: row.MerchantDisplayName,
				Phone:       row.MerchantPhone,
			},
			CreatedAt:   row.CreatedAt,
			ActivatedAt: row.ActivatedAt,
		}
	}

	c.JSON(http.StatusOK, gin.H{"codes": out})
}

// getMerchantFees — сколько всего комиссии заплатил конкретный мерчант.
func (s *Server) getMerchantFees(c *gin.Context) {
	merchant, ok := s.getAdminUserByID(c)
	if !ok {
		return
	}
	if merchant.Type != store.UserTypeMerchant {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "user is not a merchant")
		return
	}

	total, err := s.q.GetMerchantFeesPaid(c.Request.Context(), merchant.ID)
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"merchant_id": merchant.ID, "total_fees_paid": total})
}

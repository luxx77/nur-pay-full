package api

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/nurpay/backend/internal/store"
)

const (
	defaultHistoryLimit = 50
	maxHistoryLimit     = 200
)

// counterparty — вторая сторона проводки глазами текущего пользователя.
type counterparty struct {
	UserID      uuid.UUID `json:"user_id"`
	UserType    string    `json:"user_type"`
	DisplayName *string   `json:"display_name"`
	Phone       *string   `json:"phone"`
}

// entryResponse — одна проводка. Направление считается относительно того,
// кто спрашивает: одна и та же строка для плательщика «out», для
// получателя «in».
type entryResponse struct {
	ID           int64        `json:"id"`
	Type         string       `json:"type"`
	Direction    string       `json:"direction"`
	Amount       int64        `json:"amount"`
	ParentID     *int64       `json:"parent_id"`
	Counterparty counterparty `json:"counterparty"`
	CreatedAt    time.Time    `json:"created_at"`
}

func newEntryResponse(
	viewerID uuid.UUID,
	entry store.Ledger,
	other counterparty,
) entryResponse {
	direction := "in"
	if entry.FromUserID == viewerID {
		direction = "out"
	}

	return entryResponse{
		ID:           entry.ID,
		Type:         string(entry.Type),
		Direction:    direction,
		Amount:       entry.Amount,
		ParentID:     entry.ParentID,
		Counterparty: other,
		CreatedAt:    entry.CreatedAt,
	}
}

// listOperations отдаёт историю текущего пользователя.
func (s *Server) listOperations(c *gin.Context) {
	user := CurrentUser(c)

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

// getOperation отдаёт операцию целиком: основную проводку и комиссию.
func (s *Server) getOperation(c *gin.Context) {
	user := CurrentUser(c)

	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "operation id must be a number")
		return
	}

	rows, err := s.q.GetOperationEntries(c.Request.Context(), store.GetOperationEntriesParams{
		FromUserID: user.ID,
		ID:         id,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}
	// Пустой ответ означает и «нет такой операции», и «она не ваша»:
	// различать их наружу незачем.
	if len(rows) == 0 {
		Fail(c, http.StatusNotFound, CodeNotFound, "operation not found")
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

// getBalance считает баланс по книге проводок.
func (s *Server) getBalance(c *gin.Context) {
	user := CurrentUser(c)

	balance, err := s.q.GetBalance(c.Request.Context(), user.ID)
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"balance": balance})
}

// paging читает limit и offset, отвечая ошибкой на мусор в параметрах.
func paging(c *gin.Context) (limit, offset int32, ok bool) {
	limit = defaultHistoryLimit

	if raw := c.Query("limit"); raw != "" {
		parsed, err := strconv.ParseInt(raw, 10, 32)
		if err != nil || parsed <= 0 || parsed > maxHistoryLimit {
			Fail(c, http.StatusBadRequest, CodeBadRequest,
				"limit must be between 1 and "+strconv.Itoa(maxHistoryLimit))
			return 0, 0, false
		}
		limit = int32(parsed)
	}

	if raw := c.Query("offset"); raw != "" {
		parsed, err := strconv.ParseInt(raw, 10, 32)
		if err != nil || parsed < 0 {
			Fail(c, http.StatusBadRequest, CodeBadRequest,
				"offset must be zero or greater")
			return 0, 0, false
		}
		offset = int32(parsed)
	}

	return limit, offset, true
}

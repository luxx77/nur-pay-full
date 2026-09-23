package api

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/nurpay/backend/internal/store"
)

// publicUserResponse — то, что можно показать про чужой счёт: имя, номер
// и тип. Ни секрета, ни баланса.
type publicUserResponse struct {
	UserID      uuid.UUID `json:"user_id"`
	UserType    string    `json:"user_type"`
	DisplayName *string   `json:"display_name"`
	Phone       *string   `json:"phone"`
}

// getUserByQR — кто стоит за отсканированным постоянным QR.
//
// Нужен до перевода: экран подтверждения показывает получателя раньше,
// чем деньги уходят. Иначе отправитель подтверждал бы перевод вслепую.
func (s *Server) getUserByQR(c *gin.Context) {
	qrUUID, err := uuid.Parse(c.Param("qr"))
	if err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest,
			"public_qr_uuid must be a uuid")
		return
	}

	user, err := s.q.GetUserByPublicQRUUID(c.Request.Context(), qrUUID)
	if errors.Is(err, pgx.ErrNoRows) {
		Fail(c, http.StatusNotFound, CodeNotFound, "user not found")
		return
	}
	if err != nil {
		FailInternal(c, err)
		return
	}

	// Системные счета наружу не показываем — переводить на них нельзя,
	// значит и знать о них незачем.
	if user.Type == store.UserTypeSystem {
		Fail(c, http.StatusNotFound, CodeNotFound, "user not found")
		return
	}

	c.JSON(http.StatusOK, publicUserResponse{
		UserID:      user.ID,
		UserType:    string(user.Type),
		DisplayName: user.DisplayName,
		Phone:       user.Phone,
	})
}

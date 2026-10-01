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
// и тип. Ни секрета, ни баланса. public_qr_uuid отдаём тоже — им переводят
// без нового скана, если получателя уже нашли по номеру телефона.
type publicUserResponse struct {
	UserID       uuid.UUID `json:"user_id"`
	UserType     string    `json:"user_type"`
	DisplayName  *string   `json:"display_name"`
	Phone        *string   `json:"phone"`
	PublicQRUUID uuid.UUID `json:"public_qr_uuid"`
}

func newPublicUserResponse(user store.User) publicUserResponse {
	return publicUserResponse{
		UserID:       user.ID,
		UserType:     string(user.Type),
		DisplayName:  user.DisplayName,
		Phone:        user.Phone,
		PublicQRUUID: user.PublicQrUuid,
	}
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

	c.JSON(http.StatusOK, newPublicUserResponse(user))
}

// lookupPhonesRequest — номера телефонов с устройства, которые сверяем
// с базой. Само устройство не знает, кто из контактов уже в Nur Pay.
type lookupPhonesRequest struct {
	Phones []string `json:"phones"`
}

type lookupPhonesResponse struct {
	Matches []publicUserResponse `json:"matches"`
}

// maxLookupPhones — верхняя граница на размер списка за один запрос:
// на телефоне могут быть тысячи контактов, а нам нужна лишь защита от
// случайного или злонамеренного слишком большого тела запроса.
const maxLookupPhones = 2000

// lookupPhones — экран «выбрать из контактов»: какие номера из телефонной
// книги уже зарегистрированы в Nur Pay. Незарегистрированные молча
// отбрасываются — фронт сам показывает их отдельным списком.
func (s *Server) lookupPhones(c *gin.Context) {
	var req lookupPhonesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}
	if len(req.Phones) > maxLookupPhones {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "too many phones")
		return
	}

	phones := dedupeNonEmpty(req.Phones)
	if len(phones) == 0 {
		c.JSON(http.StatusOK, lookupPhonesResponse{Matches: []publicUserResponse{}})
		return
	}

	users, err := s.q.ListUsersByPhones(c.Request.Context(), phones)
	if err != nil {
		FailInternal(c, err)
		return
	}

	matches := make([]publicUserResponse, len(users))
	for i, user := range users {
		matches[i] = newPublicUserResponse(user)
	}
	c.JSON(http.StatusOK, lookupPhonesResponse{Matches: matches})
}

func dedupeNonEmpty(values []string) []string {
	seen := make(map[string]struct{}, len(values))
	out := make([]string, 0, len(values))
	for _, v := range values {
		if v == "" {
			continue
		}
		if _, ok := seen[v]; ok {
			continue
		}
		seen[v] = struct{}{}
		out = append(out, v)
	}
	return out
}

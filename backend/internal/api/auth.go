package api

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"net/http"
	"regexp"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/nurpay/backend/internal/store"
)

// Заголовки, которыми фронт представляется на каждом запросе.
// Это заглушка под JWT: подменой заголовка можно зайти за любого.
const (
	headerUserID   = "user_id"
	headerUserType = "user_type"
)

// contextUserKey — ключ, под которым middleware кладёт пользователя.
const contextUserKey = "nurpay.user"

type loginRequest struct {
	Phone string `json:"phone"`
}

// phonePattern — канонический номер: «+», затем 8–15 цифр, без пробелов.
var phonePattern = regexp.MustCompile(`^\+\d{8,15}$`)

// normalizePhone приводит номер к виду +99361188798: выкидывает всё, кроме
// цифр и ведущего «+» (пробелы, дефисы, скобки). Иначе один и тот же номер,
// набранный по-разному, плодил бы дубликаты аккаунтов.
func normalizePhone(raw string) (string, bool) {
	raw = strings.TrimSpace(raw)
	var b strings.Builder
	for i, r := range raw {
		switch {
		case r >= '0' && r <= '9':
			b.WriteRune(r)
		case r == '+' && i == 0:
			b.WriteRune(r)
		}
	}
	phone := b.String()
	return phone, phonePattern.MatchString(phone)
}

// userResponse — то, что фронт получает после входа.
type userResponse struct {
	UserID        uuid.UUID `json:"user_id"`
	UserType      string    `json:"user_type"`
	Phone         *string   `json:"phone"`
	DisplayName   *string   `json:"display_name"`
	PublicQRUUID  uuid.UUID `json:"public_qr_uuid"`
	PaymentSecret string    `json:"payment_secret"`
}

func newUserResponse(u store.User) userResponse {
	return userResponse{
		UserID:        u.ID,
		UserType:      string(u.Type),
		Phone:         u.Phone,
		DisplayName:   u.DisplayName,
		PublicQRUUID:  u.PublicQrUuid,
		PaymentSecret: u.PaymentSecret,
	}
}

// login — вход по номеру телефона без OTP: нет юзера, создаём;
// есть — отдаём как есть. Тип существующему пользователю не меняем:
// мерчанта назначают вручную в БД.
func (s *Server) login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}

	phone, ok := normalizePhone(req.Phone)
	if !ok {
		Fail(c, http.StatusBadRequest, CodeBadRequest,
			"phone must look like +99361188798")
		return
	}

	secret, err := newPaymentSecret()
	if err != nil {
		FailInternal(c, err)
		return
	}

	// public_qr_uuid и payment_secret уйдут в базу только при вставке:
	// существующему юзеру они не перезаписываются.
	user, err := s.q.UpsertUserByPhone(c.Request.Context(), store.UpsertUserByPhoneParams{
		Phone:         &phone,
		PublicQrUuid:  uuid.New(),
		PaymentSecret: secret,
	})
	if err != nil {
		FailInternal(c, err)
		return
	}

	c.JSON(http.StatusOK, newUserResponse(user))
}

// me отдаёт те же данные, что и вход: фронту нужно восстанавливать
// состояние после перезапуска, не заводя юзера заново.
func (s *Server) me(c *gin.Context) {
	c.JSON(http.StatusOK, newUserResponse(CurrentUser(c)))
}

// authRequired читает user_id и user_type из заголовков и сверяет тип с
// базой. Несовпадение типа — отдельный код: по нему фронт разлогинивается.
func (s *Server) authRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		rawID := strings.TrimSpace(c.GetHeader(headerUserID))
		rawType := strings.TrimSpace(c.GetHeader(headerUserType))

		if rawID == "" || rawType == "" {
			Fail(c, http.StatusUnauthorized, CodeUnauthorized,
				"user_id and user_type headers are required")
			return
		}

		userID, err := uuid.Parse(rawID)
		if err != nil {
			Fail(c, http.StatusUnauthorized, CodeUnauthorized,
				"user_id must be a uuid")
			return
		}

		user, err := s.q.GetUserByID(c.Request.Context(), userID)
		if errors.Is(err, pgx.ErrNoRows) {
			Fail(c, http.StatusUnauthorized, CodeUnauthorized, "unknown user")
			return
		}
		if err != nil {
			FailInternal(c, err)
			return
		}

		if string(user.Type) != rawType {
			Fail(c, http.StatusForbidden, CodeUserTypeMismatch,
				"user_type does not match the account")
			return
		}

		c.Set(contextUserKey, user)
		c.Next()
	}
}

// CurrentUser достаёт пользователя, положенного authRequired.
// Вызывается только из обработчиков за этим middleware.
func CurrentUser(c *gin.Context) store.User {
	return c.MustGet(contextUserKey).(store.User)
}

// newPaymentSecret — секрет подписи платёжного QR, 32 случайных байта.
func newPaymentSecret() (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return hex.EncodeToString(buf), nil
}

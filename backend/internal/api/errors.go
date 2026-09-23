package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Код ошибки — машиночитаемая строка. Фронт принимает решения по ней,
// message нужен только человеку в логах и на отладке.
const (
	// CodeBadRequest — тело или параметры запроса не разобрались.
	CodeBadRequest = "bad_request"

	// CodeNotFound — объекта с такими реквизитами нет.
	CodeNotFound = "not_found"

	// CodeInternal — всё остальное; наружу подробности не уходят.
	CodeInternal = "internal_error"

	// CodeUnauthorized — запрос без обязательных заголовков авторизации.
	CodeUnauthorized = "unauthorized"

	// CodeForbidden — действие не для этой роли. В отличие от
	// user_type_mismatch разлогинивать по нему не нужно.
	CodeForbidden = "forbidden"

	// CodeUserTypeMismatch — тип в заголовке не совпал с типом в БД.
	// По этому коду фронт разлогинивает пользователя.
	CodeUserTypeMismatch = "user_type_mismatch"

	// CodeInsufficientFunds — на счёте плательщика не хватает денег.
	CodeInsufficientFunds = "insufficient_funds"

	// CodeCodeAlreadyUsed — код активации не существует или уже погашен.
	CodeCodeAlreadyUsed = "code_already_used"

	// CodeQRExpired — QR-коду оплаты больше 30 секунд.
	CodeQRExpired = "qr_expired"

	// CodeNonceUsed — по этому QR уже платили.
	CodeNonceUsed = "nonce_used"

	// CodeAmountExceedsMax — сумма больше разрешённой в QR.
	CodeAmountExceedsMax = "amount_exceeds_max"

	// CodeInvalidSignature — подпись QR не сошлась.
	CodeInvalidSignature = "invalid_signature"
)

// ErrorResponse — единственный формат ошибки во всём API.
type ErrorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// Fail завершает обработку запроса ошибкой в общем формате.
func Fail(c *gin.Context, status int, code, message string) {
	c.AbortWithStatusJSON(status, ErrorResponse{Code: code, Message: message})
}

// FailInternal прячет внутреннюю причину, но кладёт её в контекст gin,
// чтобы она попала в лог.
func FailInternal(c *gin.Context, err error) {
	_ = c.Error(err)
	Fail(c, http.StatusInternalServerError, CodeInternal, "internal error")
}

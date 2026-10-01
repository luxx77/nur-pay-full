// Package api собирает HTTP-слой: маршруты, middleware, обработчики.
package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/nurpay/backend/internal/config"
	"github.com/nurpay/backend/internal/store"
)

// Server держит зависимости обработчиков.
type Server struct {
	cfg  config.Config
	pool *pgxpool.Pool
	q    *store.Queries
}

// NewServer собирает роутер со всеми маршрутами.
func NewServer(cfg config.Config, pool *pgxpool.Pool) *gin.Engine {
	s := &Server{cfg: cfg, pool: pool, q: store.New(pool)}

	router := gin.New()
	router.Use(gin.Logger(), gin.Recovery(), corsMiddleware())

	// Без этого 405 не отличить от 404.
	router.HandleMethodNotAllowed = true

	// Даже промахи по маршруту отвечают общим форматом ошибки — иначе
	// фронту пришлось бы разбирать два разных вида ответа.
	router.NoRoute(func(c *gin.Context) {
		Fail(c, http.StatusNotFound, CodeNotFound, "route not found")
	})
	router.NoMethod(func(c *gin.Context) {
		Fail(c, http.StatusMethodNotAllowed, CodeNotFound, "method not allowed")
	})

	router.GET("/healthz", s.health)
	router.POST("/auth/login", s.login)

	// Всё за этой группой требует заголовков user_id и user_type.
	authed := router.Group("", s.authRequired())
	authed.GET("/me", s.me)
	authed.GET("/balance", s.getBalance)
	authed.GET("/users/by-qr/:qr", s.getUserByQR)
	authed.POST("/users/lookup-phones", s.lookupPhones)
	authed.POST("/transfers", s.createTransfer)
	authed.GET("/operations", s.listOperations)
	authed.GET("/operations/:id", s.getOperation)
	authed.POST("/activation-codes/activate", s.activate)

	// Приём оплаты — только для торговых точек.
	merchant := authed.Group("/merchant", requireType(store.UserTypeMerchant))
	merchant.POST("/payments", s.createMerchantPayment)

	// Админка — не пользовательское действие, отдельный ключ.
	admin := router.Group("/admin", s.adminRequired())
	admin.POST("/activation-codes", s.createActivationCode)
	admin.GET("/activation-codes", s.listAdminActivationCodes)
	admin.GET("/users", s.listAdminUsers)
	admin.GET("/users/:id", s.getAdminUser)
	admin.GET("/users/:id/operations", s.listAdminUserOperations)
	admin.POST("/users/:id/topup", s.topupUser)
	admin.GET("/merchants/:id/fees", s.getMerchantFees)
	admin.GET("/fees/balance", s.getFeesBalance)
	admin.GET("/fees/operations", s.listAdminFeeOperations)

	return router
}

// corsMiddleware пускает Flutter-web с любого dev-хоста: у него порт
// каждый раз свой (flutter run сам выбирает), закрепить allowlist нечем.
// Origin отражаем как есть — с credentials здесь не работают (заголовки
// авторизации свои, не cookie), так что это не открывает ничего лишнего.
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Vary", "Origin")
			c.Header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			c.Header("Access-Control-Allow-Headers", "Content-Type, user_id, user_type, admin_api_key")
		}
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}

// health отвечает 200, только если жива и база: иначе оркестратор
// увидит «живой» сервис, который не может выполнить ни одного запроса.
func (s *Server) health(c *gin.Context) {
	if err := s.pool.Ping(c.Request.Context()); err != nil {
		Fail(c, http.StatusServiceUnavailable, CodeInternal, "database unavailable")
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

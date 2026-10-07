package api

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// Сколько живёт админский токен.
const adminTokenTTL = 8 * time.Hour

// Лимит неудачных входов с одного IP: после него — 429 до конца окна.
const (
	adminLoginMaxFailures = 5
	adminLoginWindow      = 15 * time.Minute
)

type adminLoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// loginLimiter считает неудачные попытки входа по IP. Состояние в памяти:
// админка одна, сервис один, для прототипа этого достаточно.
type loginLimiter struct {
	mu       sync.Mutex
	failures map[string][]time.Time
}

func newLoginLimiter() *loginLimiter {
	return &loginLimiter{failures: make(map[string][]time.Time)}
}

func (l *loginLimiter) blocked(ip string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	cutoff := time.Now().Add(-adminLoginWindow)
	recent := l.failures[ip][:0]
	for _, t := range l.failures[ip] {
		if t.After(cutoff) {
			recent = append(recent, t)
		}
	}
	if len(recent) == 0 {
		delete(l.failures, ip)
	} else {
		l.failures[ip] = recent
	}
	return len(recent) >= adminLoginMaxFailures
}

func (l *loginLimiter) fail(ip string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.failures[ip] = append(l.failures[ip], time.Now())
}

func (l *loginLimiter) reset(ip string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	delete(l.failures, ip)
}

// secureEqual сравнивает строки за постоянное время: хешируем, чтобы
// длина секрета тоже не утекала по времени ответа.
func secureEqual(a, b string) bool {
	ha := sha256.Sum256([]byte(a))
	hb := sha256.Sum256([]byte(b))
	return subtle.ConstantTimeCompare(ha[:], hb[:]) == 1
}

// signAdminToken выпускает токен вида "<unix-expiry>.<hmac>".
func (s *Server) signAdminToken(expires time.Time) string {
	payload := strconv.FormatInt(expires.Unix(), 10)
	return payload + "." + s.adminTokenMAC(payload)
}

func (s *Server) adminTokenMAC(payload string) string {
	mac := hmac.New(sha256.New, []byte(s.cfg.AdminTokenSecret))
	mac.Write([]byte("nurpay-admin:" + payload))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func (s *Server) validAdminToken(token string) bool {
	payload, sig, ok := strings.Cut(token, ".")
	if !ok {
		return false
	}
	if !hmac.Equal([]byte(sig), []byte(s.adminTokenMAC(payload))) {
		return false
	}
	exp, err := strconv.ParseInt(payload, 10, 64)
	return err == nil && time.Now().Unix() < exp
}

// adminLogin проверяет логин/пароль админа (они лежат только на сервере)
// и отдаёт подписанный токен с ограниченным сроком жизни.
func (s *Server) adminLogin(c *gin.Context) {
	ip := c.ClientIP()
	if s.adminLimiter.blocked(ip) {
		Fail(c, http.StatusTooManyRequests, CodeUnauthorized,
			"too many failed attempts, try again later")
		return
	}

	var req adminLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, CodeBadRequest, "invalid json body")
		return
	}

	// Обе проверки выполняются всегда, чтобы по времени ответа нельзя
	// было понять, какое из полей неверно.
	userOK := secureEqual(req.Username, s.cfg.AdminUsername)
	passOK := secureEqual(req.Password, s.cfg.AdminPassword)
	if !userOK || !passOK {
		s.adminLimiter.fail(ip)
		Fail(c, http.StatusUnauthorized, CodeUnauthorized, "invalid credentials")
		return
	}

	s.adminLimiter.reset(ip)
	expires := time.Now().Add(adminTokenTTL)
	c.JSON(http.StatusOK, gin.H{
		"token":      s.signAdminToken(expires),
		"expires_at": expires.UTC().Format(time.RFC3339),
	})
}

// adminRequired пропускает дальше только с валидным неистёкшим токеном
// в заголовке Authorization: Bearer <token>.
func (s *Server) adminRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		token, ok := strings.CutPrefix(c.GetHeader("Authorization"), "Bearer ")
		if !ok || !s.validAdminToken(strings.TrimSpace(token)) {
			Fail(c, http.StatusUnauthorized, CodeUnauthorized,
				"admin token is missing, invalid or expired")
			return
		}
		c.Next()
	}
}

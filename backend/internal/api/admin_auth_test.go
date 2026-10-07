package api

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/nurpay/backend/internal/config"
)

func newAdminTestRouter() (*gin.Engine, *Server) {
	gin.SetMode(gin.TestMode)
	s := &Server{
		cfg: config.Config{
			AdminUsername:    "admin",
			AdminPassword:    "secret-pass",
			AdminTokenSecret: strings.Repeat("k", 32),
		},
		adminLimiter: newLoginLimiter(),
	}
	r := gin.New()
	r.POST("/admin/login", s.adminLogin)
	r.GET("/admin/ping", s.adminRequired(), func(c *gin.Context) { c.Status(http.StatusOK) })
	return r, s
}

func do(r http.Handler, method, path, body, auth string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	if auth != "" {
		req.Header.Set("Authorization", auth)
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func TestAdminAuth(t *testing.T) {
	r, s := newAdminTestRouter()

	if w := do(r, "GET", "/admin/ping", "", ""); w.Code != 401 {
		t.Fatalf("no token: got %d", w.Code)
	}
	if w := do(r, "GET", "/admin/ping", "", "Bearer 9999999999.forged"); w.Code != 401 {
		t.Fatalf("forged token: got %d", w.Code)
	}
	expired := s.signAdminToken(time.Now().Add(-time.Minute))
	if w := do(r, "GET", "/admin/ping", "", "Bearer "+expired); w.Code != 401 {
		t.Fatalf("expired token: got %d", w.Code)
	}

	if w := do(r, "POST", "/admin/login", `{"username":"admin","password":"bad"}`, ""); w.Code != 401 {
		t.Fatalf("bad password: got %d", w.Code)
	}
	w := do(r, "POST", "/admin/login", `{"username":"admin","password":"secret-pass"}`, "")
	if w.Code != 200 {
		t.Fatalf("good login: got %d", w.Code)
	}
	token := w.Body.String()[strings.Index(w.Body.String(), `"token":"`)+9:]
	token = token[:strings.Index(token, `"`)]
	if w := do(r, "GET", "/admin/ping", "", "Bearer "+token); w.Code != 200 {
		t.Fatalf("valid token: got %d", w.Code)
	}
}

func TestAdminLoginRateLimit(t *testing.T) {
	r, _ := newAdminTestRouter()
	for i := 0; i < adminLoginMaxFailures; i++ {
		do(r, "POST", "/admin/login", `{"username":"admin","password":"bad"}`, "")
	}
	if w := do(r, "POST", "/admin/login", `{"username":"admin","password":"secret-pass"}`, ""); w.Code != 429 {
		t.Fatalf("expected 429 after failures, got %d", w.Code)
	}
}

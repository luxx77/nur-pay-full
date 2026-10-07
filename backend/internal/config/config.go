// Package config читает настройки процесса из окружения.
package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config — все настройки сервиса. Значений по умолчанию для комиссий нет
// намеренно: тариф должен быть задан явно, а не унаследован из кода.
type Config struct {
	DatabaseURL string
	HTTPAddr    string

	// ActivationFeePercent — комиссия при активации кода пополнения, %.
	ActivationFeePercent int64

	// MerchantPaymentFeePercent — комиссия при оплате мерчанту, %.
	MerchantPaymentFeePercent int64

	// Логин и пароль админки. Проверяются только на сервере.
	AdminUsername string
	AdminPassword string

	// AdminTokenSecret — ключ подписи админских токенов (HMAC), не короче
	// 32 символов. Смена ключа разлогинивает всех админов.
	AdminTokenSecret string

	ShutdownTimeout time.Duration
}

// Load читает .env (если он есть) и собирает конфиг из окружения.
// Переменные окружения имеют приоритет над файлом.
func Load() (Config, error) {
	// Отсутствие .env — норма: в докере переменные приходят из окружения.
	_ = godotenv.Load()

	cfg := Config{
		HTTPAddr:        getEnv("HTTP_ADDR", ":8080"),
		ShutdownTimeout: 10 * time.Second,
	}

	var err error
	if cfg.DatabaseURL, err = requireEnv("DATABASE_URL"); err != nil {
		return Config{}, err
	}
	if cfg.ActivationFeePercent, err = requirePercent("ACTIVATION_FEE"); err != nil {
		return Config{}, err
	}
	if cfg.MerchantPaymentFeePercent, err = requirePercent("MERCHANT_PAYMENT_FEE"); err != nil {
		return Config{}, err
	}
	if cfg.AdminUsername, err = requireEnv("ADMIN_USERNAME"); err != nil {
		return Config{}, err
	}
	if cfg.AdminPassword, err = requireEnv("ADMIN_PASSWORD"); err != nil {
		return Config{}, err
	}
	if cfg.AdminTokenSecret, err = requireEnv("ADMIN_TOKEN_SECRET"); err != nil {
		return Config{}, err
	}
	if len(cfg.AdminTokenSecret) < 32 {
		return Config{}, fmt.Errorf("ADMIN_TOKEN_SECRET must be at least 32 characters")
	}

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func requireEnv(key string) (string, error) {
	value := os.Getenv(key)
	if value == "" {
		return "", fmt.Errorf("%s is not set", key)
	}
	return value, nil
}

// requirePercent читает целый процент в диапазоне 0..100.
func requirePercent(key string) (int64, error) {
	raw, err := requireEnv(key)
	if err != nil {
		return 0, err
	}

	percent, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("%s must be an integer: %w", key, err)
	}
	if percent < 0 || percent > 100 {
		return 0, fmt.Errorf("%s must be between 0 and 100, got %d", key, percent)
	}
	return percent, nil
}

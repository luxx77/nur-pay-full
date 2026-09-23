// Команда api — HTTP-сервис Nur Pay.
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"

	"github.com/nurpay/backend/internal/api"
	"github.com/nurpay/backend/internal/config"
	"github.com/nurpay/backend/internal/db"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("nurpay: %v", err)
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(
		context.Background(),
		syscall.SIGINT,
		syscall.SIGTERM,
	)
	defer stop()

	cfg, err := config.Load()
	if err != nil {
		return err
	}

	pool, err := db.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()

	server := &http.Server{
		Addr:    cfg.HTTPAddr,
		Handler: api.NewServer(cfg, pool),
	}

	serverErr := make(chan error, 1)
	go func() {
		log.Printf("nurpay: listening on %s", cfg.HTTPAddr)
		if err := server.ListenAndServe(); err != nil &&
			!errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
		}
	}()

	select {
	case err := <-serverErr:
		return err
	case <-ctx.Done():
		log.Print("nurpay: shutting down")
	}

	shutdownCtx, cancel := context.WithTimeout(
		context.Background(),
		cfg.ShutdownTimeout,
	)
	defer cancel()

	return server.Shutdown(shutdownCtx)
}

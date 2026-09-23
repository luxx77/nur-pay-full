package store

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

// InTx выполняет fn в одной транзакции.
//
// Каждая денежная операция проходит через неё: проверка баланса и запись
// проводок должны быть неделимы, иначе параллельные списания уведут счёт
// в минус. Ошибка из fn откатывает всё.
//
// Файл написан руками; sqlc его не перезаписывает.
func InTx(
	ctx context.Context,
	pool *pgxpool.Pool,
	fn func(q *Queries) error,
) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}
	// Откат после успешного коммита — no-op, поэтому defer безопасен.
	defer func() { _ = tx.Rollback(ctx) }()

	if err := fn(New(tx)); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

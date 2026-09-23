-- name: LockUserForUpdate :one
-- Блокирует строку плательщика до конца транзакции. Параллельное
-- списание с того же счёта встанет здесь и увидит уже записанную
-- проводку, когда первая транзакция закоммитится.
SELECT id FROM users WHERE id = $1 FOR UPDATE;

-- name: GetBalance :one
-- Поля баланса нет: он всегда считается по книге проводок.
SELECT COALESCE(
    SUM(CASE WHEN to_user_id = $1 THEN amount ELSE -amount END),
    0
)::bigint AS balance
FROM ledger
WHERE from_user_id = $1 OR to_user_id = $1;

-- name: InsertLedgerEntry :one
INSERT INTO ledger (from_user_id, to_user_id, amount, type, parent_id, nonce)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING *;

-- name: ListUserEntries :many
-- История: проводки, в которых участвует пользователь, свежие сверху.
-- Вторая сторона подтягивается сразу, чтобы не ходить за ней по одной.
SELECT
    sqlc.embed(l),
    cp.id           AS counterparty_id,
    cp.type         AS counterparty_type,
    cp.display_name AS counterparty_display_name,
    cp.phone        AS counterparty_phone
FROM ledger l
JOIN users cp
    ON cp.id = CASE
        WHEN l.from_user_id = $1 THEN l.to_user_id
        ELSE l.from_user_id
    END
WHERE l.from_user_id = $1 OR l.to_user_id = $1
ORDER BY l.id DESC
LIMIT $2 OFFSET $3;

-- name: GetOperationEntries :many
-- Операция целиком: основная проводка и её комиссия. Видно только те
-- проводки, в которых участвует сам запрашивающий: комиссия мерчанта
-- не должна быть видна плательщику.
SELECT
    sqlc.embed(l),
    cp.id           AS counterparty_id,
    cp.type         AS counterparty_type,
    cp.display_name AS counterparty_display_name,
    cp.phone        AS counterparty_phone
FROM ledger l
JOIN users cp
    ON cp.id = CASE
        WHEN l.from_user_id = $1 THEN l.to_user_id
        ELSE l.from_user_id
    END
WHERE (l.id = $2 OR l.parent_id = $2)
  AND (l.from_user_id = $1 OR l.to_user_id = $1)
ORDER BY l.id;

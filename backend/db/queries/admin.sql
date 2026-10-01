-- name: ListUsers :many
-- Список пользователей для админки: поиск по телефону/имени, фильтр по
-- типу. Системные счета не отдаём — ими управляют не через эту ручку.
SELECT * FROM users
WHERE type != 'system'
  AND (sqlc.narg('user_type')::user_type IS NULL OR type = sqlc.narg('user_type'))
  AND (
    sqlc.narg('search')::text IS NULL
    OR phone ILIKE '%' || sqlc.narg('search')::text || '%'
    OR display_name ILIKE '%' || sqlc.narg('search')::text || '%'
  )
ORDER BY created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: ListFeeEntries :many
-- Все проводки комиссий, свежие сверху. Плательщик комиссии — from_user_id.
SELECT
    sqlc.embed(l),
    p.id           AS payer_id,
    p.type         AS payer_type,
    p.display_name AS payer_display_name,
    p.phone        AS payer_phone
FROM ledger l
JOIN users p ON p.id = l.from_user_id
WHERE l.type = 'fee'
ORDER BY l.id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: GetMerchantFeesPaid :one
-- Сколько всего комиссии заплатил мерчант со всех оплат, принятых им.
SELECT COALESCE(SUM(amount), 0)::bigint AS total
FROM ledger
WHERE type = 'fee' AND from_user_id = $1;

-- name: ListUserEntriesInRange :many
-- То же самое, что ListUserEntries, но с окном по времени — для
-- помесячного вида в админке (транзакции и комиссии мерчанта за месяц).
SELECT
    sqlc.embed(l),
    cp.id           AS counterparty_id,
    cp.type         AS counterparty_type,
    cp.display_name AS counterparty_display_name,
    cp.phone        AS counterparty_phone
FROM ledger l
JOIN users cp
    ON cp.id = CASE
        WHEN l.from_user_id = sqlc.arg('user_id') THEN l.to_user_id
        ELSE l.from_user_id
    END
WHERE (l.from_user_id = sqlc.arg('user_id') OR l.to_user_id = sqlc.arg('user_id'))
  AND l.created_at >= sqlc.arg('from')
  AND l.created_at < sqlc.arg('to')
ORDER BY l.id DESC;

-- name: ListActivationCodes :many
-- Коды для админки: свежие сверху, с фильтром по статусу. Код хранится
-- и отдаётся как есть — маскировка только на фронте, это не секрет
-- после выпуска, а предмет учёта.
SELECT
    ac.*,
    m.display_name AS merchant_display_name,
    m.phone        AS merchant_phone
FROM activation_codes ac
JOIN users m ON m.id = ac.merchant_id
WHERE sqlc.narg('status')::activation_code_status IS NULL
   OR ac.status = sqlc.narg('status')
ORDER BY ac.created_at DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

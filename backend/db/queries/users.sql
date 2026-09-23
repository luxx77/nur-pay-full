-- name: UpsertUserByPhone :one
-- Вход без OTP: нет юзера — создаём, есть — возвращаем как есть.
-- DO UPDATE вместо DO NOTHING нужен, чтобы RETURNING отдал существующую
-- строку: при DO NOTHING конфликтующая вставка не возвращает ничего.
INSERT INTO users (phone, type, public_qr_uuid, payment_secret)
VALUES ($1, 'user', $2, $3)
ON CONFLICT (phone) DO UPDATE
    SET phone = EXCLUDED.phone
RETURNING *;

-- name: GetUserByID :one
SELECT * FROM users WHERE id = $1;

-- name: GetUserByPublicQRUUID :one
SELECT * FROM users WHERE public_qr_uuid = $1;

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

-- name: ListUsersByPhones :many
-- Кто из списка номеров (контактов с телефона) уже в Nur Pay — для
-- экрана «выбрать из контактов». Системные счета не отдаём: на них
-- не переводят.
--
-- Сравниваем по последним 8 цифрам, а не строкой целиком: код страны в
-- приложении всегда +993, а в телефонной книге номера хранятся как
-- попало — с ним, без него, с пробелами. Восемь цифр — это ровно
-- локальный номер абонента (см. валидацию на экране входа).
SELECT * FROM users
WHERE type = 'user'
  AND right(regexp_replace(coalesce(phone, ''), '\D', '', 'g'), 8)
      = ANY(sqlc.arg(phones)::text[]);

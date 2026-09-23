-- name: CreateActivationCode :one
INSERT INTO activation_codes (code, amount, merchant_id)
VALUES ($1, $2, $3)
RETURNING *;

-- name: RedeemActivationCode :one
-- Погашение атомарно: условие status = 'active' в самом UPDATE.
-- Если строк не обновилось, код либо не существует, либо уже использован —
-- второй активации того же кода не случится даже при гонке.
UPDATE activation_codes
SET status       = 'used',
    activated_by = $2,
    activated_at = now()
WHERE code = $1
  AND status = 'active'
RETURNING *;

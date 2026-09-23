-- +goose Up
-- +goose StatementBegin
-- Системные счета с фиксированными идентификаторами: на них ссылается код,
-- поэтому id не должен зависеть от порядка выполнения сида.
--
-- issuance — источник денег при активации кодов, его баланс уходит в минус:
-- минус равен тому, сколько денег всего выпущено в систему.
-- fees — сюда приходят все комиссии.
--
-- payment_secret системным счетам не нужен: они ничего не подписывают.
INSERT INTO users (id, phone, type, display_name, public_qr_uuid, payment_secret)
VALUES
    (
        '00000000-0000-4000-8000-000000000001',
        NULL,
        'system',
        'issuance',
        '00000000-0000-4000-8000-0000000000a1',
        'system-account-no-signing'
    ),
    (
        '00000000-0000-4000-8000-000000000002',
        NULL,
        'system',
        'fees',
        '00000000-0000-4000-8000-0000000000a2',
        'system-account-no-signing'
    )
ON CONFLICT (id) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM users
WHERE id IN (
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000002'
);
-- +goose StatementEnd

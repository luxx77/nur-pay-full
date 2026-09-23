-- +goose Up
-- +goose StatementBegin
CREATE TYPE user_type AS ENUM ('user', 'merchant', 'system');

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- У системных счетов телефона нет: они не логинятся.
    phone           TEXT UNIQUE,

    type            user_type   NOT NULL DEFAULT 'user',

    -- Название торговой точки; юзер видит его при оплате.
    display_name    TEXT,

    -- Статичный публичный QR для приёма P2P-переводов.
    public_qr_uuid  UUID        NOT NULL UNIQUE,

    -- Секрет подписи QR оплаты. Генерится один раз на юзера.
    payment_secret  TEXT        NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT users_phone_required
        CHECK (type = 'system' OR phone IS NOT NULL)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE users;
DROP TYPE user_type;
-- +goose StatementEnd

-- +goose Up
-- +goose StatementBegin
CREATE TYPE activation_code_status AS ENUM ('active', 'used');

-- Код активации — обещание денег, проданное за наличку через мерчанта.
-- В ledger при создании кода ничего не пишется: деньги появляются
-- только в момент активации.
CREATE TABLE activation_codes (
    id           BIGSERIAL PRIMARY KEY,

    -- То, что напечатано на карте и вводится руками.
    code         TEXT                   NOT NULL UNIQUE,

    amount       BIGINT                 NOT NULL CHECK (amount > 0),

    -- Через какого мерчанта продан код.
    merchant_id  UUID                   NOT NULL REFERENCES users (id),

    status       activation_code_status NOT NULL DEFAULT 'active',

    activated_by UUID REFERENCES users (id),
    activated_at TIMESTAMPTZ,

    created_at   TIMESTAMPTZ            NOT NULL DEFAULT now(),

    -- Погашенный код всегда знает, кем и когда погашен; активный — нет.
    CONSTRAINT activation_codes_used_consistent
        CHECK (
            (status = 'used')
                = (activated_by IS NOT NULL)
                AND (activated_by IS NULL) = (activated_at IS NULL)
        )
);

CREATE INDEX activation_codes_merchant_idx ON activation_codes (merchant_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE activation_codes;
DROP TYPE activation_code_status;
-- +goose StatementEnd

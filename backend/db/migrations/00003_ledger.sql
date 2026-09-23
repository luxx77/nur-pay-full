-- +goose Up
-- +goose StatementBegin
CREATE TYPE ledger_entry_type AS ENUM (
    'activation',
    'p2p',
    'merchant_payment',
    'fee'
);

-- Источник правды для балансов. Проводки только добавляются:
-- ни UPDATE, ни DELETE по ним не выполняются нигде в коде.
CREATE TABLE ledger (
    -- Последовательный id, а не UUID: у книги проводок должен быть
    -- строгий порядок. У основной проводки и её комиссии одинаковый
    -- created_at (now() — время транзакции), и различает их только id.
    id           BIGSERIAL PRIMARY KEY,

    from_user_id UUID              NOT NULL REFERENCES users (id),
    to_user_id   UUID              NOT NULL REFERENCES users (id),

    -- Теңңе, целое. Всегда строго больше нуля: направление задают
    -- from/to, а не знак суммы.
    amount       BIGINT            NOT NULL CHECK (amount > 0),

    type         ledger_entry_type NOT NULL,

    -- У проводки-комиссии ссылается на основную проводку.
    parent_id    BIGINT REFERENCES ledger (id),

    -- uuid v7 из QR оплаты мерчанту: защита от повторного списания.
    nonce        UUID UNIQUE,

    created_at   TIMESTAMPTZ       NOT NULL DEFAULT now(),

    CONSTRAINT ledger_distinct_sides
        CHECK (from_user_id <> to_user_id),

    -- Комиссия всегда висит на основной проводке, основная — ни на чём.
    CONSTRAINT ledger_fee_has_parent
        CHECK ((type = 'fee') = (parent_id IS NOT NULL)),

    -- nonce бывает только у оплаты мерчанту.
    CONSTRAINT ledger_nonce_only_for_payment
        CHECK (nonce IS NULL OR type = 'merchant_payment')
);

-- Баланс и история читаются по каждой стороне отдельно, поэтому индекса
-- два. id в индексе — чтобы история отдавалась без досортировки.
CREATE INDEX ledger_from_user_idx ON ledger (from_user_id, id DESC);
CREATE INDEX ledger_to_user_idx ON ledger (to_user_id, id DESC);
CREATE INDEX ledger_parent_idx ON ledger (parent_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE ledger;
DROP TYPE ledger_entry_type;
-- +goose StatementEnd

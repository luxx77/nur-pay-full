-- +goose NO TRANSACTION
-- +goose Up
-- +goose StatementBegin
ALTER TYPE ledger_entry_type ADD VALUE IF NOT EXISTS 'admin_topup';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Postgres не умеет убирать значение enum обратно; откат нецелесообразен.
SELECT 1;
-- +goose StatementEnd

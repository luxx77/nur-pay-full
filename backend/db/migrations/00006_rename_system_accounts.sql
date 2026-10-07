-- +goose Up
-- +goose StatementBegin
-- Служебные имена видны людям: в истории пополнений и в админке.
UPDATE users SET display_name = 'Nur Pay'
WHERE id = '00000000-0000-4000-8000-000000000001';

UPDATE users SET display_name = 'Nur Pay komissiýasy'
WHERE id = '00000000-0000-4000-8000-000000000002';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
UPDATE users SET display_name = 'issuance'
WHERE id = '00000000-0000-4000-8000-000000000001';

UPDATE users SET display_name = 'fees'
WHERE id = '00000000-0000-4000-8000-000000000002';
-- +goose StatementEnd

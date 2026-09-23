# Все команды берут переменные из .env — он же образец для окружения.
include .env
export

MIGRATIONS := db/migrations

.PHONY: help
help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-16s %s\n", $$1, $$2}'

.PHONY: tools
tools: ## Поставить sqlc и goose
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	go install github.com/pressly/goose/v3/cmd/goose@latest

.PHONY: db-up
db-up: ## Поднять Postgres
	docker compose up -d
	docker compose exec -T postgres sh -c 'until pg_isready -U nurpay -d nurpay; do sleep 1; done'

.PHONY: db-down
db-down: ## Остановить Postgres
	docker compose down

.PHONY: db-reset
db-reset: ## Снести базу вместе с данными и поднять заново
	docker compose down -v
	$(MAKE) db-up
	$(MAKE) migrate-up

.PHONY: migrate-up
migrate-up: ## Накатить миграции
	goose -dir $(MIGRATIONS) postgres "$(DATABASE_URL)" up

.PHONY: migrate-down
migrate-down: ## Откатить последнюю миграцию
	goose -dir $(MIGRATIONS) postgres "$(DATABASE_URL)" down

.PHONY: migrate-status
migrate-status: ## Показать состояние миграций
	goose -dir $(MIGRATIONS) postgres "$(DATABASE_URL)" status

.PHONY: migrate-new
migrate-new: ## Создать миграцию: make migrate-new name=add_users
	goose -dir $(MIGRATIONS) create $(name) sql

.PHONY: generate
generate: ## Сгенерировать код из SQL
	sqlc generate

.PHONY: run
run: ## Запустить API
	go run ./cmd/api

.PHONY: build
build: ## Собрать бинарь в ./bin/api
	go build -o bin/api ./cmd/api

.PHONY: tidy
tidy: ## Привести go.mod в порядок
	go mod tidy

#!/usr/bin/env bash
set -euo pipefail

# Выполняется на сервере пользователем deploy, вызывается из GitHub Actions.
# /opt/nurpay — корень репозитория, /opt/nurpay/backend — сам Go-бэкенд.

cd /opt/nurpay
git fetch origin
git checkout "$1"
git reset --hard "origin/$1"

cd backend
docker compose up -d
docker compose exec -T postgres sh -c 'until pg_isready -U nurpay -d nurpay; do sleep 1; done'

export $(grep -v '^#' .env | xargs)
$(go env GOPATH)/bin/goose -dir db/migrations postgres "$DATABASE_URL" up

go build -o bin/api ./cmd/api

sudo systemctl restart nurpay-api

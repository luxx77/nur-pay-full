#!/usr/bin/env bash
set -euo pipefail

# Разовый запуск бэкенда на сервере: код уже выложен, нужно просто поднять.
# Поднимает Postgres (docker compose), прогоняет миграции, собирает бинарь
# и запускает его — через systemd, если есть root, иначе через nohup.
#
# Использование: ./deploy/start.sh
# (повторный запуск безопасен — пересобирает и перезапускает сервис)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
cd "$BACKEND_DIR"

echo "==> Рабочая директория: $BACKEND_DIR"

if [ ! -f .env ]; then
  echo "==> .env не найден, создаю из .env.example"
  cp .env.example .env
  echo "!!! Проверь .env перед продолжением (ADMIN_USERNAME/ADMIN_PASSWORD/ADMIN_TOKEN_SECRET, порты и т.п.)"
fi

command -v docker >/dev/null || { echo "docker не найден"; exit 1; }
command -v go >/dev/null || { echo "go не найден"; exit 1; }

echo "==> Поднимаю Postgres"
docker compose up -d
docker compose exec -T postgres sh -c 'until pg_isready -U nurpay -d nurpay; do sleep 1; done'

GOOSE="$(go env GOPATH)/bin/goose"
if [ ! -x "$GOOSE" ]; then
  echo "==> Ставлю goose"
  go install github.com/pressly/goose/v3/cmd/goose@latest
fi

set -a
source .env
set +a

echo "==> Прогоняю миграции"
"$GOOSE" -dir db/migrations postgres "$DATABASE_URL" up

echo "==> Собираю бинарь"
go build -o bin/api ./cmd/api

if [ "$(id -u)" -eq 0 ] && command -v systemctl >/dev/null; then
  echo "==> Запускаю через systemd"
  UNIT_SRC="$SCRIPT_DIR/nurpay-api.service"
  UNIT_DST="/etc/systemd/system/nurpay-api.service"
  SERVICE_USER="${SUDO_USER:-root}"
  sed \
    -e "s#WorkingDirectory=.*#WorkingDirectory=$BACKEND_DIR#" \
    -e "s#EnvironmentFile=.*#EnvironmentFile=$BACKEND_DIR/.env#" \
    -e "s#ExecStart=.*#ExecStart=$BACKEND_DIR/bin/api#" \
    -e "s#^User=.*#User=$SERVICE_USER#" \
    "$UNIT_SRC" > "$UNIT_DST"
  systemctl daemon-reload
  systemctl enable --now nurpay-api
  systemctl restart nurpay-api
  sleep 1
  systemctl --no-pager status nurpay-api
else
  echo "==> Нет root/systemd, запускаю через nohup"
  mkdir -p logs
  PID_FILE="nurpay-api.pid"
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "==> Останавливаю предыдущий процесс ($(cat "$PID_FILE"))"
    kill "$(cat "$PID_FILE")"
    sleep 1
  fi
  nohup ./bin/api > logs/api.log 2>&1 &
  echo $! > "$PID_FILE"
  echo "==> Запущено, PID $(cat "$PID_FILE"), логи в logs/api.log"
fi

sleep 1
HTTP_ADDR_PORT="${HTTP_ADDR#:}"
curl -fsS "http://localhost:${HTTP_ADDR_PORT:-8080}/healthz" && echo || echo "!!! healthz не ответил, смотри логи"

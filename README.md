# Nur Pay

Closed-loop электронный кошелёк для Туркменистана: переводы между
пользователями и оплата в магазине по одноразовому QR. Деньги двигаются
только внутри платформы. Прототип для презентации, ориентир — Touch 'n Go.

Монорепозиторий из трёх частей:

| папка                  | что это                         | стек                                         |
|------------------------|---------------------------------|----------------------------------------------|
| [`mobile/`](mobile)    | приложение для клиента и мерчанта | Flutter, BLoC (кубиты), dio, go_router       |
| [`backend/`](backend)  | API и книга проводок            | Go, Gin, Postgres, pgx/v5, sqlc, goose       |
| [`admin/`](admin)      | веб-админка                     | React 19, TypeScript, Vite                   |

Спецификация — [`NurPayTZ.md`](NurPayTZ.md).

## Скриншоты

UI на туркменском (латиница). Снято на iPhone 17 Pro.

### Вход

<p>
  <img src="docs/screenshots/01-login.png" width="200" alt="Ввод номера">
  <img src="docs/screenshots/02-otp.png" width="200" alt="Код из SMS">
  <img src="docs/screenshots/03-pin.png" width="200" alt="Создание PIN">
</p>

### Кошелёк

<p>
  <img src="docs/screenshots/04-home.png" width="200" alt="Главный экран">
  <img src="docs/screenshots/05-history.png" width="200" alt="История">
  <img src="docs/screenshots/06-operation.png" width="200" alt="Детали операции">
  <img src="docs/screenshots/07-profile.png" width="200" alt="Профиль">
</p>

### Оплата в магазине

Клиент задаёт лимит и подтверждает PIN. Приложение показывает одноразовый
QR, подписанный HMAC, и само обновляет его каждые 30 секунд. Касса
набирает сумму и сканирует код.

<p>
  <img src="docs/screenshots/12-pay-limit.png" width="200" alt="Лимит оплаты">
  <img src="docs/screenshots/13-pay-qr.png" width="200" alt="Одноразовый QR">
</p>

### Переводы и пополнение

<p>
  <img src="docs/screenshots/08-my-qr.png" width="200" alt="Мой постоянный QR">
  <img src="docs/screenshots/09-transfer-scan.png" width="200" alt="Сканер перевода">
  <img src="docs/screenshots/10-topup.png" width="200" alt="Способ пополнения">
  <img src="docs/screenshots/11-activation-code.png" width="200" alt="Код активации">
</p>

## Как устроено

* **Деньги** хранятся целыми числами в теңңе (1 манат = 100 теңңе), без
  float.
* **Баланс** нигде не хранится: он считается по книге проводок
  (`ledger`), куда записи только добавляются. Сумма всех балансов,
  включая системные счета эмиссии и комиссий, всегда равна нулю.
* **Списание** идёт одной транзакцией: `SELECT … FOR UPDATE` по
  плательщику, чтение баланса, вставка проводок. Баланс не уходит в минус
  даже при параллельных запросах.
* **Однократность** обеспечивает база, а не код: код активации гасится
  условным `UPDATE`, повторную оплату по одному QR ловит уникальный
  индекс на `nonce`.
* **Комиссию** платит получатель: `floor(amount * percent / 100)`,
  процент задаётся в `.env`.
* **Роль** (клиент или мерчант) определяет сервер. Вкладки и цветовая
  схема приложения следуют за ней.

Подробности — в README каждой части.

## Запуск локально

```bash
# 1. Бэкенд
cd backend
cp .env.example .env
make db-up && make migrate-up && make run   # API на :8080

# 2. Приложение
cd ../mobile
cp .env.example .env    # NURPAY_API_URL=http://localhost:8080
flutter run

# 3. Админка
cd ../admin
cp .env.example .env
npm install && npm run dev
```

Кода из SMS на сервере нет: экран оставлен как шаг сценария, подойдёт
любой. PIN локальный, сервер о нём не знает.

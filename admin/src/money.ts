// Сумма в манатах, хранится в теňňe (1 TMT = 100 teňňe) — повторяет
// mobile/lib/core/money.dart, чтобы ввод и вид совпадали с приложением.
const MAX_WHOLE_DIGITS = 7;

export function pushDigit(minor: number, digit: string): number {
  const d = Number(digit);
  if (Number.isNaN(d)) return minor;
  const next = minor * 10 + d;
  if (Math.floor(next / 100).toString().length > MAX_WHOLE_DIGITS) return minor;
  return next;
}

export function backspace(minor: number): number {
  return Math.floor(minor / 10);
}

// «1 240,00» — пробел между тысячами, запятая перед теňňe.
export function formatMoney(minor: number): string {
  const sign = minor < 0 ? "−" : "";
  const abs = Math.abs(minor);
  const whole = Math.floor(abs / 100).toString();
  const fraction = (abs % 100).toString().padStart(2, "0");

  let grouped = "";
  for (let i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 === 0) grouped += " ";
    grouped += whole[i];
  }
  return `${sign}${grouped},${fraction}`;
}

export function formatMoneyWithCurrency(minor: number): string {
  return `${formatMoney(minor)} TMT`;
}

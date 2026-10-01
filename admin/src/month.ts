// "2026-10" -> текущий месяц в формате <input type="month">.
export function currentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
}

export function daysInMonth(month: string): number {
  const [year, m] = month.split("-").map(Number);
  return new Date(year, m, 0).getDate();
}

// Границы месяца как RFC3339 — половинный интервал [from, to).
export function monthRange(month: string): { from: string; to: string } {
  const [year, m] = month.split("-").map(Number);
  const from = new Date(year, m - 1, 1);
  const to = new Date(year, m, 1);
  return { from: from.toISOString(), to: to.toISOString() };
}

export function dayOfMonth(iso: string): number {
  return new Date(iso).getDate();
}

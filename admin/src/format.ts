import { formatMoneyWithCurrency } from "./money";

export function formatAmount(minor: number): string {
  return formatMoneyWithCurrency(minor);
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleString("ru-RU");
}

export function userLabel(name: string | null, phone: string | null): string {
  return name ?? phone ?? "—";
}

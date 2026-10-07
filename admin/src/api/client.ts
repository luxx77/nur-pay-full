import { env } from "../env";
import { getToken, logout } from "../auth";
import type { ActivationCode, ActivationCodeListItem, AdminUser, Entry, FeeEntry } from "./types";

export class ApiError extends Error {
  status: number;
  code: string;

  constructor(status: number, code: string, message: string) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${env.apiBaseUrl}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${getToken() ?? ""}`,
      ...init?.headers,
    },
  });

  if (res.status === 401) {
    // Токен истёк или не принят бэкендом — возвращаем на экран входа.
    logout();
    window.location.assign("/login");
  }

  if (!res.ok) {
    let code = "unknown";
    let message = res.statusText;
    try {
      const body = await res.json();
      code = body.code ?? code;
      message = body.message ?? message;
    } catch {
      // тело не json — оставляем statusText
    }
    throw new ApiError(res.status, code, message);
  }

  if (res.status === 204) {
    return undefined as T;
  }
  return res.json() as Promise<T>;
}

export interface ListUsersParams {
  limit?: number;
  offset?: number;
  type?: "user" | "merchant";
  search?: string;
}

function toQuery(params: object): string {
  const q = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== "") q.set(key, String(value));
  }
  const s = q.toString();
  return s ? `?${s}` : "";
}

export const api = {
  listUsers: (params: ListUsersParams = {}) =>
    request<{ users: AdminUser[] }>(`/admin/users${toQuery(params)}`),

  getUser: (id: string) => request<AdminUser>(`/admin/users/${id}`),

  listUserOperations: (id: string, limit = 50, offset = 0) =>
    request<{ entries: Entry[] }>(
      `/admin/users/${id}/operations${toQuery({ limit, offset })}`,
    ),

  listUserOperationsInRange: (id: string, fromISO: string, toISO: string) =>
    request<{ entries: Entry[] }>(
      `/admin/users/${id}/operations${toQuery({ from: fromISO, to: toISO })}`,
    ),

  topupUser: (id: string, amount: number) =>
    request<{ entry: Entry; balance: number }>(`/admin/users/${id}/topup`, {
      method: "POST",
      body: JSON.stringify({ amount }),
    }),

  createActivationCode: (amount: number, merchantId: string) =>
    request<ActivationCode>("/admin/activation-codes", {
      method: "POST",
      body: JSON.stringify({ amount, merchant_id: merchantId }),
    }),

  listActivationCodes: (status?: "active" | "used", limit = 100, offset = 0) =>
    request<{ codes: ActivationCodeListItem[] }>(
      `/admin/activation-codes${toQuery({ status, limit, offset })}`,
    ),

  getFeesBalance: () => request<{ balance: number }>("/admin/fees/balance"),

  listFeeOperations: (limit = 50, offset = 0) =>
    request<{ entries: FeeEntry[] }>(
      `/admin/fees/operations${toQuery({ limit, offset })}`,
    ),

  getMerchantFees: (id: string) =>
    request<{ merchant_id: string; total_fees_paid: number }>(
      `/admin/merchants/${id}/fees`,
    ),
};

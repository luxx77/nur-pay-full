export type UserType = "user" | "merchant" | "system";

export interface AdminUser {
  user_id: string;
  user_type: UserType;
  display_name: string | null;
  phone: string | null;
  balance: number;
  created_at: string;
}

export interface Counterparty {
  user_id: string;
  user_type: UserType;
  display_name: string | null;
  phone: string | null;
}

export interface Entry {
  id: number;
  type: string;
  direction: "in" | "out";
  amount: number;
  parent_id: number | null;
  counterparty: Counterparty;
  created_at: string;
}

export interface FeeEntry {
  id: number;
  amount: number;
  parent_id: number | null;
  payer: Counterparty;
  created_at: string;
}

export interface ActivationCode {
  id: number;
  code: string;
  amount: number;
  merchant_id: string;
  status: string;
}

export interface ActivationCodeListItem {
  id: number;
  code: string;
  amount: number;
  status: "active" | "used";
  merchant: Counterparty;
  created_at: string;
  activated_at: string | null;
}

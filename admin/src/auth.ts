import { env } from "./env";

// Логин — заглушка: один логин/пароль из .env, без бэкенда и токена.
// После успеха просто пишем флаг в localStorage.
const STORAGE_KEY = "admin_logged_in";

export function isLoggedIn(): boolean {
  return localStorage.getItem(STORAGE_KEY) === "true";
}

export function login(username: string, password: string): boolean {
  const ok = username === env.adminUsername && password === env.adminPassword;
  if (ok) {
    localStorage.setItem(STORAGE_KEY, "true");
  }
  return ok;
}

export function logout(): void {
  localStorage.removeItem(STORAGE_KEY);
}

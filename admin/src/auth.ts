import { env } from "./env";

// Настоящая проверка логина и пароля — на бэкенде (POST /admin/login).
// Здесь хранится только выданный токен: в sessionStorage, чтобы он
// пропадал при закрытии вкладки. isLoggedIn нужен лишь для UI — подделка
// токена ничего не даёт, бэкенд проверяет подпись и срок на каждом запросе.
const TOKEN_KEY = "admin_token";
const EXPIRES_KEY = "admin_token_expires_at";

export function getToken(): string | null {
  return sessionStorage.getItem(TOKEN_KEY);
}

export function isLoggedIn(): boolean {
  const token = getToken();
  if (!token) return false;
  const expires = Date.parse(sessionStorage.getItem(EXPIRES_KEY) ?? "");
  if (!Number.isNaN(expires) && Date.now() >= expires) {
    logout();
    return false;
  }
  return true;
}

export async function login(username: string, password: string): Promise<boolean> {
  const res = await fetch(`${env.apiBaseUrl}/admin/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });
  if (res.status === 401) return false;
  if (!res.ok) throw new Error(`login failed: ${res.status}`);

  const body = (await res.json()) as { token: string; expires_at: string };
  sessionStorage.setItem(TOKEN_KEY, body.token);
  sessionStorage.setItem(EXPIRES_KEY, body.expires_at);
  return true;
}

export function logout(): void {
  sessionStorage.removeItem(TOKEN_KEY);
  sessionStorage.removeItem(EXPIRES_KEY);
}

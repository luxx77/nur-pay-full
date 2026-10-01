// Читает конфиг из .env (см. .env.example). Падаем сразу и явно, если
// чего-то не хватает — лучше белый экран с понятной ошибкой в консоли,
// чем тихо сломанные запросы к API.
function requireEnv(key: string): string {
  const value = import.meta.env[key];
  if (!value) {
    throw new Error(`${key} is not set — скопируйте .env.example в .env`);
  }
  return value;
}

export const env = {
  apiBaseUrl: requireEnv("VITE_API_BASE_URL").replace(/\/+$/, ""),
  adminApiKey: requireEnv("VITE_ADMIN_API_KEY"),
  adminUsername: requireEnv("VITE_ADMIN_USERNAME"),
  adminPassword: requireEnv("VITE_ADMIN_PASSWORD"),
};

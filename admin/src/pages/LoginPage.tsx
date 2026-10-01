import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { login } from "../auth";
import { t } from "../i18n";

export function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (login(username, password)) {
      navigate("/users", { replace: true });
    } else {
      setError(t.login.error);
    }
  }

  return (
    <div className="login-page">
      <form className="login-form page-transition" onSubmit={handleSubmit}>
        <div className="login-logo">
          <img src="/logo.svg" alt="" />
        </div>
        <h1>{t.appName}</h1>
        <label>
          {t.login.username}
          <input
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            autoFocus
          />
        </label>
        <label>
          {t.login.password}
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </label>
        {error && <p className="error">{error}</p>}
        <button type="submit">{t.login.submit}</button>
      </form>
    </div>
  );
}

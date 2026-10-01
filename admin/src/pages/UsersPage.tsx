import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import type { AdminUser } from "../api/types";
import { formatAmount, formatDate, userLabel } from "../format";
import { t } from "../i18n";

export function UsersPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [search, setSearch] = useState("");
  const [type, setType] = useState<"" | "user" | "merchant">("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const handle = setTimeout(() => {
      setLoading(true);
      setError(null);
      api
        .listUsers({ search: search || undefined, type: type || undefined, limit: 100 })
        .then((res) => setUsers(res.users))
        .catch((e) => setError(String(e.message ?? e)))
        .finally(() => setLoading(false));
    }, 250);
    return () => clearTimeout(handle);
  }, [search, type]);

  return (
    <div>
      <h1>{t.users.title}</h1>
      <div className="toolbar">
        <input
          placeholder={t.users.searchPlaceholder}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <select value={type} onChange={(e) => setType(e.target.value as typeof type)}>
          <option value="">{t.users.allTypes}</option>
          <option value="user">{t.users.typeUser}</option>
          <option value="merchant">{t.users.typeMerchant}</option>
        </select>
      </div>

      {error && <p className="error">{error}</p>}
      {loading ? (
        <p>{t.users.loading}</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>{t.users.colName}</th>
              <th>{t.users.colType}</th>
              <th>{t.users.colBalance}</th>
              <th>{t.users.colCreated}</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.user_id}>
                <td>
                  <Link to={`/users/${u.user_id}`}>
                    {userLabel(u.display_name, u.phone)}
                  </Link>
                </td>
                <td>
                  <span className={u.user_type === "merchant" ? "badge badge-accent" : "badge badge-muted"}>
                    {u.user_type === "merchant" ? t.users.merchantType : t.users.userType}
                  </span>
                </td>
                <td>{formatAmount(u.balance)}</td>
                <td>{formatDate(u.created_at)}</td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr>
                <td colSpan={4}>{t.users.empty}</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

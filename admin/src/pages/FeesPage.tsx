import { useEffect, useState } from "react";
import { api } from "../api/client";
import type { FeeEntry } from "../api/types";
import { formatAmount, formatDate, userLabel } from "../format";
import { t } from "../i18n";

export function FeesPage() {
  const [balance, setBalance] = useState<number | null>(null);
  const [entries, setEntries] = useState<FeeEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    Promise.all([api.getFeesBalance(), api.listFeeOperations(100)])
      .then(([b, ops]) => {
        setBalance(b.balance);
        setEntries(ops.entries);
      })
      .catch((e) => setError(String(e.message ?? e)))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div>
      <h1>{t.fees.title}</h1>
      {error && <p className="error">{error}</p>}
      <div className="card-row">
        <div className="card">
          <div className="card-label">{t.fees.totalAccrued}</div>
          <div className="card-value">
            {balance === null ? "…" : formatAmount(balance)}
          </div>
        </div>
      </div>

      <h2>{t.fees.history}</h2>
      {loading ? (
        <p>{t.fees.loading}</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>{t.fees.colDate}</th>
              <th>{t.fees.colAmount}</th>
              <th>{t.fees.colPayer}</th>
              <th>{t.fees.colPayerType}</th>
            </tr>
          </thead>
          <tbody>
            {entries.map((e) => (
              <tr key={e.id}>
                <td>{formatDate(e.created_at)}</td>
                <td>{formatAmount(e.amount)}</td>
                <td>{userLabel(e.payer.display_name, e.payer.phone)}</td>
                <td>{e.payer.user_type === "merchant" ? t.users.merchantType : t.users.userType}</td>
              </tr>
            ))}
            {entries.length === 0 && (
              <tr>
                <td colSpan={4}>{t.fees.empty}</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

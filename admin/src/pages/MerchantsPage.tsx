import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import type { AdminUser } from "../api/types";
import { formatAmount, formatDate, userLabel } from "../format";
import { t } from "../i18n";

interface Row extends AdminUser {
  totalFeesPaid: number;
}

export function MerchantsPage() {
  const [rows, setRows] = useState<Row[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    api
      .listUsers({ type: "merchant", limit: 200 })
      .then(async (res) => {
        const withFees = await Promise.all(
          res.users.map(async (u) => {
            const fees = await api.getMerchantFees(u.user_id);
            return { ...u, totalFeesPaid: fees.total_fees_paid };
          }),
        );
        setRows(withFees);
      })
      .catch((e) => setError(String(e.message ?? e)))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div>
      <h1>{t.merchants.title}</h1>
      {error && <p className="error">{error}</p>}
      {loading ? (
        <p>{t.merchants.loading}</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>{t.merchants.colName}</th>
              <th>{t.merchants.colBalance}</th>
              <th>{t.merchants.colTotalFees}</th>
              <th>{t.users.colCreated}</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((m) => (
              <tr key={m.user_id}>
                <td>
                  <Link to={`/merchants/${m.user_id}`}>
                    {userLabel(m.display_name, m.phone)}
                  </Link>
                </td>
                <td>{formatAmount(m.balance)}</td>
                <td>{formatAmount(m.totalFeesPaid)}</td>
                <td>{formatDate(m.created_at)}</td>
              </tr>
            ))}
            {rows.length === 0 && (
              <tr>
                <td colSpan={4}>{t.merchants.empty}</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

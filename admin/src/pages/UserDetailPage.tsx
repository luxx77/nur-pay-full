import { useEffect, useState, type FormEvent } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "../api/client";
import type { AdminUser, Entry } from "../api/types";
import { AmountInput } from "../components/AmountInput";
import { formatAmount, formatDate, userLabel } from "../format";
import { t } from "../i18n";

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [user, setUser] = useState<AdminUser | null>(null);
  const [entries, setEntries] = useState<Entry[]>([]);
  const [merchantFees, setMerchantFees] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [topupAmount, setTopupAmount] = useState(0);
  const [topupError, setTopupError] = useState<string | null>(null);
  const [topupBusy, setTopupBusy] = useState(false);

  function load() {
    if (!id) return;
    setLoading(true);
    setError(null);
    Promise.all([api.getUser(id), api.listUserOperations(id)])
      .then(([u, ops]) => {
        setUser(u);
        setEntries(ops.entries);
        if (u.user_type === "merchant") {
          return api.getMerchantFees(id).then((r) => setMerchantFees(r.total_fees_paid));
        }
      })
      .catch((e) => setError(String(e.message ?? e)))
      .finally(() => setLoading(false));
  }

  useEffect(load, [id]);

  async function handleTopup(e: FormEvent) {
    e.preventDefault();
    if (!id) return;
    if (topupAmount <= 0) {
      setTopupError(t.userDetail.topupAmountError);
      return;
    }
    setTopupBusy(true);
    setTopupError(null);
    try {
      await api.topupUser(id, topupAmount);
      setTopupAmount(0);
      load();
    } catch (err) {
      setTopupError(String((err as Error).message ?? err));
    } finally {
      setTopupBusy(false);
    }
  }

  if (loading) return <p>{t.userDetail.loading}</p>;
  if (error) return <p className="error">{error}</p>;
  if (!user) return null;

  return (
    <div>
      <p>
        <Link to="/users">{t.userDetail.back}</Link>
      </p>
      <h1>{userLabel(user.display_name, user.phone)}</h1>
      <div className="card-row">
        <div className="card">
          <div className="card-label">{t.userDetail.type}</div>
          <div className="card-value">
            {user.user_type === "merchant" ? t.users.merchantType : t.users.userType}
          </div>
        </div>
        <div className="card">
          <div className="card-label">{t.userDetail.balance}</div>
          <div className="card-value">{formatAmount(user.balance)}</div>
        </div>
        {merchantFees !== null && (
          <div className="card">
            <div className="card-label">{t.userDetail.totalFeesPaid}</div>
            <div className="card-value">{formatAmount(merchantFees)}</div>
          </div>
        )}
      </div>

      <h2>{t.userDetail.topupTitle}</h2>
      <form className="inline-form" onSubmit={handleTopup}>
        <AmountInput minor={topupAmount} onChange={setTopupAmount} />
        <button type="submit" disabled={topupBusy}>
          {topupBusy ? t.userDetail.topupBusy : t.userDetail.topupSubmit}
        </button>
      </form>
      {topupError && <p className="error">{topupError}</p>}

      <h2>{t.userDetail.transactions}</h2>
      <table className="table">
        <thead>
          <tr>
            <th>{t.userDetail.colDate}</th>
            <th>{t.userDetail.colType}</th>
            <th>{t.userDetail.colDirection}</th>
            <th>{t.userDetail.colAmount}</th>
            <th>{t.userDetail.colCounterparty}</th>
          </tr>
        </thead>
        <tbody>
          {entries.map((e) => (
            <tr key={e.id}>
              <td>{formatDate(e.created_at)}</td>
              <td>{t.entryTypes[e.type] ?? e.type}</td>
              <td>
                <span className={e.direction === "in" ? "badge badge-success" : "badge badge-danger"}>
                  {e.direction === "in" ? t.userDetail.directionIn : t.userDetail.directionOut}
                </span>
              </td>
              <td>{formatAmount(e.amount)}</td>
              <td>{userLabel(e.counterparty.display_name, e.counterparty.phone)}</td>
            </tr>
          ))}
          {entries.length === 0 && (
            <tr>
              <td colSpan={5}>{t.userDetail.empty}</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

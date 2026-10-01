import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "../api/client";
import type { AdminUser, Entry } from "../api/types";
import { FeesChart, type DailyFee } from "../components/FeesChart";
import { formatAmount, formatDate, userLabel } from "../format";
import { t } from "../i18n";
import { currentMonth, dayOfMonth, daysInMonth, monthRange } from "../month";

export function MerchantDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [merchant, setMerchant] = useState<AdminUser | null>(null);
  const [month, setMonth] = useState(currentMonth());
  const [entries, setEntries] = useState<Entry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    api.getUser(id).catch((e) => setError(String(e.message ?? e))).then((u) => u && setMerchant(u));
  }, [id]);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    setError(null);
    const { from, to } = monthRange(month);
    api
      .listUserOperationsInRange(id, from, to)
      .then((res) => setEntries(res.entries))
      .catch((e) => setError(String(e.message ?? e)))
      .finally(() => setLoading(false));
  }, [id, month]);

  if (!id) return null;

  const feeEntries = entries.filter((e) => e.type === "fee");
  const feesByDay = new Map<number, number>();
  for (const e of feeEntries) {
    const day = dayOfMonth(e.created_at);
    feesByDay.set(day, (feesByDay.get(day) ?? 0) + e.amount);
  }
  const dailyFees: DailyFee[] = Array.from(feesByDay, ([day, amountMinor]) => ({
    day,
    amountMinor,
  }));
  const monthTotal = feeEntries.reduce((sum, e) => sum + e.amount, 0);

  return (
    <div>
      <p>
        <Link to="/merchants">{t.merchantDetail.back}</Link>
      </p>
      <h1>{merchant ? userLabel(merchant.display_name, merchant.phone) : "…"}</h1>

      <div className="card-row">
        {merchant && (
          <div className="card">
            <div className="card-label">{t.merchantDetail.balance}</div>
            <div className="card-value">{formatAmount(merchant.balance)}</div>
          </div>
        )}
        <div className="card">
          <div className="card-label">{t.merchantDetail.totalForMonth}</div>
          <div className="card-value">{formatAmount(monthTotal)}</div>
        </div>
      </div>

      <div className="toolbar">
        <label className="month-picker">
          {t.merchantDetail.month}
          <input type="month" value={month} onChange={(e) => setMonth(e.target.value)} />
        </label>
      </div>

      {error && <p className="error">{error}</p>}

      <h2>{t.merchantDetail.feesChartTitle}</h2>
      <FeesChart data={dailyFees} daysInMonth={daysInMonth(month)} />

      <h2>{t.merchantDetail.transactionsForMonth}</h2>
      {loading ? (
        <p>{t.merchantDetail.loading}</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>{t.merchantDetail.colDate}</th>
              <th>{t.merchantDetail.colType}</th>
              <th>{t.merchantDetail.colDirection}</th>
              <th>{t.merchantDetail.colAmount}</th>
              <th>{t.merchantDetail.colCounterparty}</th>
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
                <td colSpan={5}>{t.merchantDetail.empty}</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

import { useEffect, useState, type FormEvent } from "react";
import { api } from "../api/client";
import type { ActivationCodeListItem, AdminUser } from "../api/types";
import { AmountInput } from "../components/AmountInput";
import { MaskedCode } from "../components/MaskedCode";
import { formatDate, userLabel } from "../format";
import { t } from "../i18n";
import { formatMoneyWithCurrency } from "../money";

type StatusFilter = "all" | "active" | "used";

export function ActivationCodesPage() {
  const [merchants, setMerchants] = useState<AdminUser[]>([]);
  const [merchantId, setMerchantId] = useState("");
  const [amount, setAmount] = useState(0);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [codes, setCodes] = useState<ActivationCodeListItem[]>([]);
  const [filter, setFilter] = useState<StatusFilter>("all");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api
      .listUsers({ type: "merchant", limit: 200 })
      .then((res) => {
        setMerchants(res.users);
        if (res.users.length > 0) setMerchantId(res.users[0].user_id);
      })
      .catch((e) => setError(String(e.message ?? e)));
  }, []);

  function loadCodes() {
    setLoading(true);
    api
      .listActivationCodes(filter === "all" ? undefined : filter, 200)
      .then((res) => setCodes(res.codes))
      .catch((e) => setError(String(e.message ?? e)))
      .finally(() => setLoading(false));
  }

  useEffect(loadCodes, [filter]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (amount <= 0) {
      setError(t.activationCodes.amountError);
      return;
    }
    if (!merchantId) return;
    setBusy(true);
    setError(null);
    try {
      await api.createActivationCode(amount, merchantId);
      setAmount(0);
      loadCodes();
    } catch (err) {
      setError(String((err as Error).message ?? err));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div>
      <h1>{t.activationCodes.title}</h1>
      <form className="inline-form" onSubmit={handleSubmit}>
        <select value={merchantId} onChange={(e) => setMerchantId(e.target.value)}>
          {merchants.map((m) => (
            <option key={m.user_id} value={m.user_id}>
              {userLabel(m.display_name, m.phone)}
            </option>
          ))}
        </select>
        <AmountInput minor={amount} onChange={setAmount} />
        <button type="submit" disabled={busy || merchants.length === 0}>
          {busy ? t.activationCodes.createBusy : t.activationCodes.createSubmit}
        </button>
      </form>
      {merchants.length === 0 && <p>{t.activationCodes.noMerchants}</p>}
      {error && <p className="error">{error}</p>}

      <div className="tab-bar">
        <button
          className={filter === "all" ? "tab active" : "tab"}
          onClick={() => setFilter("all")}
        >
          {t.activationCodes.filterAll}
        </button>
        <button
          className={filter === "active" ? "tab active" : "tab"}
          onClick={() => setFilter("active")}
        >
          {t.activationCodes.filterActive}
        </button>
        <button
          className={filter === "used" ? "tab active" : "tab"}
          onClick={() => setFilter("used")}
        >
          {t.activationCodes.filterUsed}
        </button>
      </div>

      {loading ? (
        <p>{t.activationCodes.loading}</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>{t.activationCodes.colCode}</th>
              <th>{t.activationCodes.colAmount}</th>
              <th>{t.activationCodes.colMerchant}</th>
              <th>{t.activationCodes.colStatus}</th>
              <th>{t.activationCodes.colCreated}</th>
            </tr>
          </thead>
          <tbody>
            {codes.map((c) => (
              <tr key={c.id}>
                <td>
                  <MaskedCode code={c.code} />
                </td>
                <td>{formatMoneyWithCurrency(c.amount)}</td>
                <td>{userLabel(c.merchant.display_name, c.merchant.phone)}</td>
                <td>
                  <span className={c.status === "active" ? "badge badge-success" : "badge badge-muted"}>
                    {c.status === "active"
                      ? t.activationCodes.statusActive
                      : t.activationCodes.statusUsed}
                  </span>
                </td>
                <td>{formatDate(c.created_at)}</td>
              </tr>
            ))}
            {codes.length === 0 && (
              <tr>
                <td colSpan={5}>{t.activationCodes.empty}</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

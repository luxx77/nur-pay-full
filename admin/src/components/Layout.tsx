import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { logout } from "../auth";
import { t } from "../i18n";

export function Layout() {
  const navigate = useNavigate();
  const location = useLocation();

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  return (
    <div className="app-shell">
      <nav className="sidebar">
        <div className="sidebar-brand">
          <img src="/logo.svg" alt="" />
          <span>{t.appName}</span>
        </div>
        <NavLink to="/users" className={navClass}>
          {t.nav.users}
        </NavLink>
        <NavLink to="/merchants" className={navClass}>
          {t.nav.merchants}
        </NavLink>
        <NavLink to="/activation-codes" className={navClass}>
          {t.nav.activationCodes}
        </NavLink>
        <NavLink to="/fees" className={navClass}>
          {t.nav.fees}
        </NavLink>
        <button className="logout-btn" onClick={handleLogout}>
          {t.nav.logout}
        </button>
      </nav>
      <main className="content">
        <div key={location.pathname} className="page-transition">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

function navClass({ isActive }: { isActive: boolean }) {
  return isActive ? "nav-link active" : "nav-link";
}

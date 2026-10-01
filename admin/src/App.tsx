import { Navigate, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { RequireAuth } from "./components/RequireAuth";
import { LoginPage } from "./pages/LoginPage";
import { UsersPage } from "./pages/UsersPage";
import { UserDetailPage } from "./pages/UserDetailPage";
import { MerchantsPage } from "./pages/MerchantsPage";
import { MerchantDetailPage } from "./pages/MerchantDetailPage";
import { ActivationCodesPage } from "./pages/ActivationCodesPage";
import { FeesPage } from "./pages/FeesPage";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        element={
          <RequireAuth>
            <Layout />
          </RequireAuth>
        }
      >
        <Route index element={<Navigate to="/users" replace />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/users/:id" element={<UserDetailPage />} />
        <Route path="/merchants" element={<MerchantsPage />} />
        <Route path="/merchants/:id" element={<MerchantDetailPage />} />
        <Route path="/activation-codes" element={<ActivationCodesPage />} />
        <Route path="/fees" element={<FeesPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/users" replace />} />
    </Routes>
  );
}

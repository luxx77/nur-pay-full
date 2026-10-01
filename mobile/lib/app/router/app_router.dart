import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_role.dart';
import '../../core/ui_kit/ui_kit.dart';
import '../../features/auth/presentation/bloc/session_cubit.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/phone_page.dart';
import '../../features/auth/presentation/pages/pin_create_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/history/presentation/pages/history_filter_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/history/presentation/widgets/history_filter.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/merchant/presentation/pages/merchant_amount_page.dart';
import '../../features/merchant/presentation/pages/merchant_home_page.dart';
import '../../features/merchant/presentation/pages/merchant_limit_exceeded_page.dart';
import '../../features/merchant/presentation/pages/merchant_result_page.dart';
import '../../features/merchant/presentation/pages/merchant_scanner_page.dart';
import '../../features/pay/presentation/pages/pay_limit_page.dart';
import '../../features/pay/presentation/pages/payment_qr_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/qr/presentation/pages/my_qr_page.dart';
import '../../features/topup/presentation/pages/activation_code_page.dart';
import '../../features/topup/presentation/pages/topup_method_page.dart';
import '../../features/topup/presentation/pages/topup_success_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/transfer/presentation/pages/transfer_amount_page.dart';
import '../../features/transfer/presentation/pages/transfer_confirm_page.dart';
import '../../features/transfer/presentation/pages/transfer_contacts_page.dart';
import '../../features/transfer/presentation/pages/transfer_scan_page.dart';
import '../../features/transfer/presentation/pages/transfer_success_page.dart';
import '../widgets/app_shell.dart';
import '../widgets/branch_switcher.dart';
import 'app_routes.dart';
import 'refresh_stream.dart';

/// Навигация приложения.
///
/// Куда пускать, решает состояние сессии: роль приходит с сервера, и
/// подменить её на клиенте нельзя.
abstract final class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter create(SessionCubit session) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(session.stream),
    redirect: (_, state) => _guard(session.state, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),

      // ── Вход ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.phone,
        pageBuilder: (_, state) => _page(state, const PhonePage()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (_, state) => _page(
          state,
          OtpPage(phone: state.uri.queryParameters['phone'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.pinCreate,
        pageBuilder: (_, state) => _page(state, const PinCreatePage()),
      ),

      // ── Вкладки кошелька ──────────────────────────────────────────────
      StatefulShellRoute(
        builder: (_, _, shell) =>
            AppShell(navigationShell: shell, role: AppRole.customer),
        navigatorContainerBuilder: _branches,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ── Вкладки кассы ─────────────────────────────────────────────────
      StatefulShellRoute(
        builder: (_, _, shell) =>
            AppShell(navigationShell: shell, role: AppRole.merchant),
        navigatorContainerBuilder: _branches,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.merchantHome,
                builder: (_, _) => const MerchantHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.merchantHistory,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.merchantProfile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ── Сценарии поверх вкладок ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.payLimit,
        pageBuilder: (_, state) => _page(state, const PayLimitPage()),
      ),
      GoRoute(
        path: AppRoutes.payQr,
        pageBuilder: (_, state) => _page(state, const PaymentQrPage()),
      ),

      GoRoute(
        path: AppRoutes.transferScan,
        pageBuilder: (_, state) => _page(state, const TransferScanPage()),
      ),
      GoRoute(
        path: AppRoutes.transferContacts,
        pageBuilder: (_, state) => _page(state, const TransferContactsPage()),
      ),
      GoRoute(
        path: AppRoutes.transferAmount,
        pageBuilder: (_, state) => _page(state, const TransferAmountPage()),
      ),
      GoRoute(
        path: AppRoutes.transferConfirm,
        pageBuilder: (_, state) => _page(state, const TransferConfirmPage()),
      ),
      GoRoute(
        path: AppRoutes.transferSuccess,
        pageBuilder: (_, state) => _page(state, const TransferSuccessPage()),
      ),

      GoRoute(
        path: AppRoutes.topUpMethod,
        pageBuilder: (_, state) => _page(state, const TopUpMethodPage()),
      ),
      GoRoute(
        path: AppRoutes.topUpCode,
        pageBuilder: (_, state) => _page(state, const ActivationCodePage()),
      ),
      GoRoute(
        path: AppRoutes.topUpAgent,
        pageBuilder: (_, state) =>
            _page(state, const MyQrPage(forAgent: true)),
      ),
      GoRoute(
        path: AppRoutes.topUpSuccess,
        pageBuilder: (_, state) => _page(state, const TopUpSuccessPage()),
      ),

      GoRoute(
        path: AppRoutes.myQr,
        pageBuilder: (_, state) => _page(state, const MyQrPage()),
      ),
      GoRoute(
        path: AppRoutes.transaction,
        pageBuilder: (_, state) => _page(
          state,
          TransactionDetailsPage(
            operationId:
                int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0,
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.merchantAmount,
        pageBuilder: (_, state) => _page(state, const MerchantAmountPage()),
      ),
      GoRoute(
        path: AppRoutes.merchantScanAccept,
        pageBuilder: (_, state) => _page(state, const MerchantScannerPage()),
      ),
      GoRoute(
        path: AppRoutes.merchantResult,
        pageBuilder: (_, state) => _page(state, const MerchantResultPage()),
      ),
      GoRoute(
        path: AppRoutes.merchantLimitExceeded,
        pageBuilder: (context, state) =>
            _dialogPage(context, state, const MerchantLimitExceededPage()),
      ),

      // ── Шторки ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.historyFilter,
        pageBuilder: (context, state) => _sheetPage(
          context,
          state,
          HistoryFilterPage(
            initial: state.extra is HistoryFilter
                ? state.extra! as HistoryFilter
                : const HistoryFilter(),
          ),
        ),
      ),
    ],
  );

  /// Куда пускать при текущем состоянии сессии.
  static String? _guard(SessionState session, String location) {
    final atSplash = location == AppRoutes.splash;
    final atAuth = AppRoutes.authRoutes.contains(location);

    switch (session) {
      // Сессию ещё читаем — держим заставку, чтобы не мигать входом.
      case SessionUnknown():
        return atSplash ? null : AppRoutes.splash;

      case SessionAbsent():
        return atAuth ? null : AppRoutes.phone;

      case SessionActive(:final pinSet, :final role):
        // Вошли, но замок не поставлен — сначала PIN.
        if (!pinSet) {
          return location == AppRoutes.pinCreate ? null : AppRoutes.pinCreate;
        }

        final home = role.isMerchant ? AppRoutes.merchantHome : AppRoutes.home;
        if (atSplash || atAuth) return home;

        // В чужие вкладки не пускаем: роль задаёт сервер.
        final merchantTab = location.startsWith(AppRoutes.merchantHome);
        if (role.isMerchant && _customerTabs.contains(location)) return home;
        if (role.isCustomer && merchantTab) return home;
        return null;
    }
  }

  static const _customerTabs = {
    AppRoutes.home,
    AppRoutes.history,
    AppRoutes.profile,
  };

  /// Обычный переход по стеку: страница приезжает справа, как в нативной
  /// навигации — `CupertinoPage` даёт этот слайд на любой платформе, не
  /// завися от того, подхватила ли тема `pageTransitionsTheme`.
  static Page<T> _page<T>(GoRouterState state, Widget child) =>
      CupertinoPage<T>(key: state.pageKey, child: child);

  /// Ветки вкладок: живые все, видна одна — с растворением между ними.
  static Widget _branches(
    BuildContext context,
    StatefulNavigationShell shell,
    List<Widget> children,
  ) => BranchSwitcher(currentIndex: shell.currentIndex, children: children);

  /// Шторка снизу: затемнение проявляется, сама шторка подъезжает.
  static Page<T> _sheetPage<T>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<T>(
    key: state.pageKey,
    opaque: false,
    barrierDismissible: true,
    barrierColor: _scrimOf(context),
    transitionDuration: AppMotion.page,
    reverseTransitionDuration: AppMotion.quick,
    child: Align(alignment: Alignment.bottomCenter, child: child),
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
          reverseCurve: AppMotion.exit,
        ),
      ),
      child: child,
    ),
  );

  /// Диалог: подрастает из центра.
  static Page<T> _dialogPage<T>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<T>(
    key: state.pageKey,
    opaque: false,
    barrierDismissible: true,
    barrierColor: _scrimOf(context),
    transitionDuration: AppMotion.medium,
    reverseTransitionDuration: AppMotion.quick,
    child: Center(child: child),
    transitionsBuilder: (_, animation, _, child) =>
        AppOverlayTransition(animation: animation, slide: 0, child: child),
  );

  static Color _scrimOf(BuildContext context) =>
      Theme.of(context).colorScheme.scrim.withValues(alpha: 0.42);
}

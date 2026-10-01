import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../../../core/money.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../widgets/home_header.dart';
import '../widgets/operation_list.dart';

/// 2.1 · Esasy — главный экран кошелька.
///
/// Главное действие — плавающая кнопка «оплатить в магазине», перевод и
/// пополнение в доке под палец.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Баланс читается при открытии вкладки и после каждой операции.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<WalletCubit>().refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletCubit>().state;
    final session = context.watch<SessionCubit>().state;
    final hasNetwork = context.watch<ConnectivityCubit>().state;
    final offline =
        !hasNetwork || wallet.stale || (wallet.error?.isNetwork ?? false);
    final recent = wallet.operations.take(4).toList();
    // Перевод и пополнение требуют сети прямо сейчас — в отличие от баланса
    // их не получится offline-first показать из кеша, поэтому доковые
    // кнопки следят за сетью отдельно, а не за «offline» всего экрана.
    final dockHeight = HomeActionDock.heightOf(withNote: !hasNetwork);

    return BlocListener<ConnectivityCubit, bool>(
      // Связь вернулась — баланс мог устареть, обновляем сразу, не дожидаясь
      // следующего открытия вкладки.
      listenWhen: (was, isNow) => !was && isNow,
      listener: (context, _) => context.read<WalletCubit>().refresh(),
      child: AppScaffold(
        padded: false,
        safeBottom: false,
        // Плавающая кнопка лежит поверх дока, иначе её тень обрезается
        // краем панели.
        body: Stack(
          children: [
            Column(
              children: [
                HomeHeader(
                  title: 'Nur Pay',
                  online: !offline,
                  onStatusTap: () => context.read<WalletCubit>().refresh(),
                  onQrTap: () => context.push(AppRoutes.myQr),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: context.read<WalletCubit>().refresh,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (offline) ...[
                          Entrance(
                            child: InfoBanner(
                              title: 'Aragatnaşyk ýok',
                              subtitle: wallet.updatedAt == null
                                  ? 'Maglumat entek ýüklenmedi'
                                  : 'Maglumatlar ${TmDate.relativeTime(wallet.updatedAt!)} täzelendi',
                            ),
                          ),
                          Gap(12.h),
                        ],
                        Entrance(
                          child: BalanceCard(
                            amount: wallet.balance ?? Money.zero,
                            caption: session is SessionActive
                                ? session.session.title
                                : 'Nur Pay',
                            stale: offline,
                          ),
                        ),
                        Gap(18.h),
                        const Entrance(
                          index: 1,
                          child: BlockTitle('Soňky amallar'),
                        ),
                        Gap(10.h),
                        Entrance(
                          index: 2,
                          child: recent.isEmpty
                              ? _EmptyOperations(loading: wallet.loading)
                              : OperationsCard(
                                  children: [
                                    for (final operation in recent)
                                      OperationRow(operation: operation),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                HomeActionDock(
                  enabled: hasNetwork,
                  note: !hasNetwork
                      ? 'Bular üçin internet gerek. '
                            'Dükanda töleg oflaýn işleýär.'
                      : null,
                  onTransfer: () => context.push(AppRoutes.transferScan),
                  onTopUp: () => context.push(AppRoutes.topUpMethod),
                ),
              ],
            ),
            Positioned(
              right: 20.w,
              bottom: dockHeight + 20.h,
              child: AppFab(
                onPressed: () => context.push(AppRoutes.payLimit),
                child: const QrGlyph(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOperations extends StatelessWidget {
  const _EmptyOperations({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: loading
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                )
              : Text(
                  'Amal ýok',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
        ),
      ),
    );
  }
}

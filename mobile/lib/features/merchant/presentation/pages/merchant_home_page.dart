import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/money.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../../../home/presentation/widgets/operation_list.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/merchant_payment_cubit.dart';

/// 7.1 · Esasy — главный экран торговой точки.
///
/// Зелёную схему и нижнюю панель даёт оболочка роли, экран о них не знает.
class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<WalletCubit>().refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletCubit>().state;
    final session = context.watch<SessionCubit>().state;
    final offline = wallet.error?.isNetwork ?? false;

    // Дневная выручка считается по приходным проводкам за сегодня.
    final now = DateTime.now();
    final today = wallet.operations.where(
      (o) =>
          o.isIncoming &&
          o.createdAt.year == now.year &&
          o.createdAt.month == now.month &&
          o.createdAt.day == now.day,
    );
    final revenue = today.fold(
      Money.zero,
      (sum, operation) => sum + operation.amount,
    );

    return AppScaffold(
      padded: false,
      safeBottom: false,
      body: Column(
        children: [
          HomeHeader(
            title: session is SessionActive ? session.session.title : 'Nur Pay',
            online: !offline,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppStatusBadge(
                  label: 'Söwda nokady',
                  tone: AppStatusTone.brand,
                ),
                SizedBox(width: 10.w),
                AppIconButton(
                  icon: Icons.qr_code_2_rounded,
                  tonal: true,
                  size: 36.r,
                  onPressed: () => context.push(AppRoutes.myQr),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: context.read<WalletCubit>().refresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Entrance(
                    child: RevenueCard(
                      amount: revenue,
                      caption: 'Şu günki düşewünt',
                      metrics: [
                        ('Amallar', '${today.length}'),
                        (
                          'Hasap galyndysy',
                          (wallet.balance ?? Money.zero).formatted,
                        ),
                      ],
                    ),
                  ),
                  Gap(14.h),
                  Entrance(
                    index: 1,
                    child: AppButton.filled(
                      label: 'Töleg kabul et',
                      onPressed: offline
                          ? null
                          : () {
                              context.read<MerchantPaymentCubit>().reset();
                              context.push(AppRoutes.merchantAmount);
                            },
                    ),
                  ),
                  Gap(18.h),
                  const Entrance(index: 2, child: BlockTitle('Soňky amallar')),
                  Gap(10.h),
                  if (wallet.operations.isNotEmpty)
                    Entrance(
                      index: 3,
                      child: OperationsCard(
                        children: [
                          for (final operation in wallet.operations.take(4))
                            OperationRow(operation: operation),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../transactions/presentation/widgets/share_sheet.dart';
import '../bloc/merchant_payment_cubit.dart';

/// 7.5 · Netije — результат у кассира.
///
/// Сумма набрана крупно: её видно через прилавок, не наклоняясь к экрану.
class MerchantResultPage extends StatelessWidget {
  const MerchantResultPage({super.key});

  @override
  Widget build(BuildContext context) => RoleTheme(
    role: AppRole.merchant,
    child: Builder(
      builder: (context) {
        final text = Theme.of(context).textTheme;
        final state = context.watch<MerchantPaymentCubit>().state;
        final payment = state.result.where((e) => !e.isFee).firstOrNull;
        final fee = state.result.where((e) => e.isFee).firstOrNull;

        void exit() {
          context.read<MerchantPaymentCubit>().reset();
          context.go(AppRoutes.merchantHome);
        }

        if (payment == null) {
          return AppScaffold(
            body: EmptyState(
              title: 'Amal tapylmady',
              message: 'Töleg barada maglumat ýok',
              actions: [
                AppButton.filled(
                  label: 'Esasy',
                  size: AppButtonSize.medium,
                  expanded: false,
                  onPressed: exit,
                ),
              ],
            ),
          );
        }

        return FlowResult(
          onExit: exit,
          child: AppScaffold(
            padded: false,
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          const ResultGlyph(tone: ResultGlyphTone.success),
                          Gap(12.h),
                          Text('Üstünlikli', style: text.headlineLarge),
                          Gap(6.h),
                          AmountText(
                            payment.netAmount(fee).formatted,
                            size: AmountSize.hero,
                          ),
                          Gap(6.h),
                          Text(
                            payment.counterparty.title,
                            textAlign: TextAlign.center,
                            style: text.headlineMedium,
                          ),
                        ],
                      ),
                      Gap(20.h),
                      DetailList.filled(
                        rows: [
                          DetailRow('Sene', TmDate.receipt(payment.createdAt)),
                          DetailRow(
                            'Amalyň belgisi',
                            '#${payment.id}',
                            mono: true,
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 64.h,
                        child: AppButton.filled(
                          label: 'Indiki',
                          onPressed: exit,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 20.w,
                  bottom: 96.h,
                  child: AppFab(
                    size: 56.r,
                    outlined: true,
                    onPressed: () => ShareSheet.show(
                      context,
                      operation: payment,
                      amount: payment.netAmount(fee),
                    ),
                    child: const Icon(Icons.ios_share_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

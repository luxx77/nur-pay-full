import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../transactions/presentation/widgets/share_sheet.dart';
import '../bloc/transfer_cubit.dart';

/// 4.4 · Geçirildi — чек отправителя.
class TransferSuccessPage extends StatelessWidget {
  const TransferSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final state = context.watch<TransferCubit>().state;
    final operation = state.result.firstOrNull;

    void exit() {
      context.read<TransferCubit>().reset();
      context.go(AppRoutes.home);
    }

    if (operation == null) {
      // Сюда не попасть обычным путём, но и падать незачем.
      return AppScaffold(
        body: EmptyState(
          title: 'Amal tapylmady',
          message: 'Geçirim barada maglumat ýok',
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
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      ResultGlyph(
                        tone: ResultGlyphTone.successSoft,
                        size: 76.r,
                      ),
                      Gap(14.h),
                      Text('Geçirildi', style: text.headlineMedium),
                      Gap(14.h),
                      AmountText(operation.amount.formatted),
                      Gap(14.h),
                      Text(
                        operation.counterparty.title,
                        style: text.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Gap(18.h),
                  DetailList.filled(
                    rows: [
                      DetailRow('Sene', TmDate.receipt(operation.createdAt)),
                      DetailRow(
                        'Amalyň belgisi',
                        '#${operation.id}',
                        mono: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton.filled(label: 'Taýýar', onPressed: exit),
                ],
              ),
            ),
            Positioned(
              right: 20.w,
              bottom: 90.h,
              child: AppFab(
                size: 56.r,
                outlined: true,
                onPressed: () => ShareSheet.show(context, operation: operation),
                child: const Icon(Icons.ios_share_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

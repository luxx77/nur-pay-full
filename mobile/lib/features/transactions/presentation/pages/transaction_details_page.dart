import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../bloc/operation_details_cubit.dart';
import '../widgets/share_sheet.dart';

/// 6.2 · Amal — чек операции.
///
/// Комиссию не показываем отдельной строкой: сумма операции уже отражает
/// то, что фактически получил или заплатил пользователь (amount − fee).
class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key, required this.operationId});

  final int operationId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        OperationDetailsCubit(context.read<WalletRepository>())
          ..load(operationId),
    child: const _DetailsView(),
  );
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final state = context.watch<OperationDetailsCubit>().state;
    final main = state.main;
    final fee = state.fee;

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Amal'),
          Expanded(
            child: switch ((state.loading, state.error, main)) {
              (true, _, _) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              ),
              (_, final error?, _) => EmptyState(
                title: 'Açyp bolmady',
                message: error.userMessage,
              ),
              (_, _, null) => const EmptyState(
                title: 'Amal tapylmady',
                message: 'Bu amal siziňki däl ýa-da ýok',
              ),
              (_, _, final operation) => ListView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                children: [
                  Gap(10.h),
                  Column(
                    children: [
                      Container(
                        width: 64.r,
                        height: 64.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: operation!.isIncoming
                              ? cs.secondaryContainer
                              : cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          operation.isIncoming
                              ? CupertinoIcons.arrow_down
                              : CupertinoIcons.arrow_up,
                          size: 28.r,
                          color: operation.isIncoming
                              ? cs.onSecondaryContainer
                              : cs.onSurface,
                        ),
                      ),
                      Gap(8.h),
                      AmountText(
                        operation.netAmount(fee).formatted,
                        tone: operation.isIncoming
                            ? AmountTone.income
                            : AmountTone.neutral,
                      ),
                      Gap(8.h),
                      Text(
                        operation.counterparty.title,
                        style: text.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Gap(14.h),
                  DetailList(
                    rows: [
                      DetailRow('Sene', TmDate.receipt(operation.createdAt)),
                      DetailRow('Görnüşi', operation.type.label),
                      DetailRow(
                        'Amalyň belgisi',
                        '#${operation.id}',
                        mono: true,
                      ),
                    ],
                  ),
                  Gap(18.h),
                  AppButton.outlined(
                    label: 'Çeki paýlaş',
                    onPressed: () => ShareSheet.show(
                      context,
                      operation: operation,
                      amount: operation.netAmount(fee),
                    ),
                  ),
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}

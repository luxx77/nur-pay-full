import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/input/amount_editor.dart';
import '../../../../core/money.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/transfer_cubit.dart';

/// 4.2 · Möçber — сумма перевода.
class TransferAmountPage extends StatefulWidget {
  const TransferAmountPage({super.key});

  @override
  State<TransferAmountPage> createState() => _TransferAmountPageState();
}

class _TransferAmountPageState extends State<TransferAmountPage> {
  late final AmountEditor _editor;

  @override
  void initState() {
    super.initState();
    _editor = AmountEditor(initial: context.read<TransferCubit>().state.amount)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final recipient = context.watch<TransferCubit>().state.recipient;
    final balance = context.watch<WalletCubit>().state.balance ?? Money.zero;

    final amount = _editor.value;
    final overBalance = amount > balance;
    final canContinue = amount.isPositive && !overBalance;

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Möçber'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (recipient != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: AppRadius.lgAll,
                      ),
                      child: Row(
                        children: [
                          AppAvatar.fromName(recipient.title, size: 40.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipient.title,
                                  style: text.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (recipient.phone != null)
                                  Text(
                                    recipient.phone!,
                                    style: text.bodySmall?.copyWith(
                                      fontSize: 13.5.sp,
                                      color: cs.onSurfaceVariant,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Pressable(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              'Üýtget',
                              style: text.labelMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Gap(18.h),
                  Center(
                    child: AmountText(
                      _editor.display,
                      size: AmountSize.display,
                      tone: overBalance ? AmountTone.error : AmountTone.neutral,
                    ),
                  ),
                  Gap(18.h),
                  Text(
                    overBalance
                        ? 'Balansda ýeterlik pul ýok'
                        : 'Balans: ${balance.withCurrency}',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: overBalance ? cs.error : cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  NumericKeypad(
                    layout: KeypadLayout.decimal,
                    onKey: _editor.push,
                    onBackspace: _editor.backspace,
                    onBackspaceLongPress: _editor.clear,
                  ),
                  Gap(14.h),
                  AppButton.filled(
                    label: 'Dowam et',
                    onPressed: canContinue
                        ? () {
                            context.read<TransferCubit>().setAmount(amount);
                            context.push(AppRoutes.transferConfirm);
                          }
                        : null,
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

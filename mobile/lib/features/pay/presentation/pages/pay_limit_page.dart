import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/input/amount_editor.dart';
import '../../../../core/money.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../pin/presentation/widgets/pin_sheet.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/payment_qr_cubit.dart';

/// 3.1 · Çäk — лимит, который клиент разрешает списать кассиру.
///
/// Лимит уходит внутрь подписанного QR: больше него касса списать не
/// сможет, даже подменив сумму в запросе.
class PayLimitPage extends StatefulWidget {
  const PayLimitPage({super.key});

  @override
  State<PayLimitPage> createState() => _PayLimitPageState();
}

class _PayLimitPageState extends State<PayLimitPage> {
  static const _presets = [20, 50, 100];

  final _editor = AmountEditor(initial: Money.zero);

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onChanged);
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _confirm() {
    final session = context.read<SessionCubit>().state;
    if (session is! SessionActive) return;

    final limit = _editor.value;
    PinSheet.show(
      context,
      title: 'PIN giriziň',
      subtitle: '${limit.withCurrency} çäkli QR dörediler',
      onCompleted: () {
        context.read<PaymentQrCubit>().start(
          limit: limit,
          userId: session.session.userId,
          paymentSecret: session.session.paymentSecret,
        );
        context.push(AppRoutes.payQr);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final balance = context.watch<WalletCubit>().state.balance ?? Money.zero;

    final limit = _editor.value;
    final overBalance = limit > balance;
    final canContinue = limit.isPositive && !overBalance;

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Dükanda töle'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kassire näçe möçbere rugsat berýärsiňiz? '
                    'Şundan köp alyp bilmez.',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Gap(16.h),
                  Center(
                    child: AmountText(
                      _editor.display,
                      size: AmountSize.display,
                      tone: overBalance ? AmountTone.error : AmountTone.neutral,
                    ),
                  ),
                  Gap(16.h),
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
                  Gap(14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final (i, preset) in _presets.indexed) ...[
                        AppChoiceChip(
                          label: '$preset',
                          tabular: true,
                          selected: limit == Money.major(preset),
                          onTap: () => _editor.setValue(Money.major(preset)),
                        ),
                        if (i != _presets.length - 1) SizedBox(width: 8.w),
                      ],
                    ],
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
                    label: 'Indiki',
                    onPressed: canContinue ? _confirm : null,
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

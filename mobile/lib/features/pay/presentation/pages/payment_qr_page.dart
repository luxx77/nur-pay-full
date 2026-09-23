import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../bloc/payment_qr_cubit.dart';

/// 3.2 · Töleg QR — одноразовый код с лимитом.
///
/// Код живёт 30 секунд и обновляется сам, как одноразовый пароль:
/// нажимать ничего не нужно.
class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Отсчёт рисуется чаще, чем меняется код: иначе полоса дёргается.
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    context.read<PaymentQrCubit>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final state = context.watch<PaymentQrCubit>().state;

    final now = DateTime.now();
    final remaining = state.remaining(now);

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(
            center: AppStatusBadge(
              label: 'Bir gezeklik',
              tone: AppStatusTone.brand,
              showDot: false,
              uppercase: true,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Text(
                        'Rugsat berlen çäk',
                        style: text.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Gap(2.h),
                      AmountText(
                        state.limit.formatted,
                        size: AmountSize.display,
                      ),
                    ],
                  ),
                  Gap(14.h),
                  Center(
                    // Смена кода — короткое растворение, чтобы подмена
                    // не выглядела подёргиванием.
                    child: AnimatedSwitcher(
                      duration: AppMotion.medium,
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: AppMotion.exit,
                      child: QrOutlinedCard(
                        key: ValueKey(state.qr?.nonce),
                        data: state.qr?.encode() ?? '',
                      ),
                    ),
                  ),
                  Gap(18.h),
                  CountdownBar(
                    label: 'Kod täzelenýär',
                    remaining: '0:${TmDate.two(remaining.inSeconds)}',
                    progress: state.progress(now),
                  ),
                  Gap(14.h),
                  Text(
                    'Kassire görkeziň. Kod diňe bir gezek işleýär '
                    'we özi täzelenýär.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

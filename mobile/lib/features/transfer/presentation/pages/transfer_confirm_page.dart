import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/money.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../pin/presentation/widgets/pin_sheet.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/transfer_cubit.dart';

/// 4.3 · Geçirimi tassykla — подтверждение перевода.
///
/// «Tassykla» поднимает шторку PIN; сам перевод уходит на сервер только
/// после верного кода.
class TransferConfirmPage extends StatelessWidget {
  const TransferConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final transfer = context.watch<TransferCubit>();
    final state = transfer.state;
    final recipient = state.recipient;

    Future<void> send() async {
      final sent = await transfer.submit();
      if (!context.mounted) return;

      if (!sent) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.error?.userMessage ?? 'Geçirim amala aşmady'),
            ),
          );
        return;
      }

      // Баланс и история изменились — перечитываем их к возврату.
      unawaited(context.read<WalletCubit>().refresh());
      context.go(AppRoutes.transferSuccess);
    }

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Geçirimi tassykla'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(10.h),
                  Column(
                    children: [
                      AppAvatar.fromName(
                        recipient?.title ?? 'Nur Pay',
                        size: 64.r,
                      ),
                      Gap(6.h),
                      Text(
                        recipient?.title ?? 'Nur Pay',
                        style: text.titleLarge,
                      ),
                      if (recipient?.isMerchant == true) ...[
                        Gap(2.h),
                        Text(
                          'Söwdagär',
                          style: text.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                      Gap(6.h),
                      AmountText(state.amount.formatted),
                    ],
                  ),
                  Gap(18.h),
                  DetailList(
                    rows: [
                      DetailRow('Kime', recipient?.phone ?? '—'),
                      DetailRow('Komissiýa', Money.zero.withCurrency),
                      DetailRow(
                        'Jemi',
                        state.amount.withCurrency,
                        emphasized: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton.filled(
                    label: 'Tassykla',
                    loading: state.busy,
                    onPressed: state.busy
                        ? null
                        : () => PinSheet.show(
                            context,
                            title: 'PIN giriziň',
                            subtitle: '${state.amount.withCurrency} geçiriler',
                            onCompleted: send,
                          ),
                  ),
                  Gap(10.h),
                  AppButton.outlined(
                    label: 'Ýatyr',
                    onPressed: () => Navigator.of(context).maybePop(),
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

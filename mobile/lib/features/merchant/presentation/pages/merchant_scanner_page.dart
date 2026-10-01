import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/network/api_error_code.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/merchant_payment_cubit.dart';

/// 7.3 · Skaner — касса читает платёжный код клиента.
///
/// Подпись, срок и лимит проверяет сервер: приложение отправляет код как
/// есть и разбирает ответ.
class MerchantScannerPage extends StatefulWidget {
  const MerchantScannerPage({super.key});

  @override
  State<MerchantScannerPage> createState() => _MerchantScannerPageState();
}

class _MerchantScannerPageState extends State<MerchantScannerPage> {
  bool _handling = false;

  Future<void> _onDetect(String raw) async {
    if (_handling) return;

    final payload = NurPayQr.tryParse(raw);
    if (payload is! PaymentQr) {
      _complain('Bu bir gezeklik töleg QR kody däl');
      return;
    }

    setState(() => _handling = true);
    final cubit = context.read<MerchantPaymentCubit>();
    final charged = await cubit.charge(payload);
    if (!mounted) return;

    if (charged) {
      unawaitedRefresh();
      context.pushReplacement(AppRoutes.merchantResult);
      return;
    }

    final error = cubit.state.error;
    if (error?.code == ApiErrorCode.amountExceedsMax) {
      // Отказ по лимиту показываем поверх сканера: кассир поправит сумму
      // и вернётся к тому же коду.
      await context.push(AppRoutes.merchantLimitExceeded);
      if (mounted) setState(() => _handling = false);
      return;
    }

    _complain(error?.userMessage ?? 'Töleg amala aşmady');
  }

  void unawaitedRefresh() => context.read<WalletCubit>().refresh();

  void _complain(String message) {
    setState(() => _handling = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => RoleTheme.dark(
    role: AppRole.merchant,
    child: Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final amount = context.watch<MerchantPaymentCubit>().state.amount;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              Positioned.fill(
                child: ScannerView(
                  accent: cs.secondary,
                  active: !_handling,
                  onDetect: _onDetect,
                  hint: _handling
                      ? 'Kod okaldy…'
                      : 'Müşderiniň bir gezeklik QR-ny skanirläň',
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ColoredBox(
                  color: cs.surface,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const AppTopBar(title: 'Çekmek'),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                          child: Row(
                            children: [
                              AmountText(
                                amount.formatted,
                                size: AmountSize.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      child: AppButton(
                        label: 'Möçberi üýtget',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

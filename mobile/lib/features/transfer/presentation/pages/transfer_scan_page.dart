import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';
import '../bloc/transfer_cubit.dart';

/// 4.1 · Kontaktlar → сканер.
///
/// Списка контактов у бэкенда нет: получатель определяется по его
/// постоянному QR, поэтому перевод начинается со сканера.
class TransferScanPage extends StatefulWidget {
  const TransferScanPage({super.key});

  @override
  State<TransferScanPage> createState() => _TransferScanPageState();
}

class _TransferScanPageState extends State<TransferScanPage> {
  bool _handling = false;

  Future<void> _onDetect(String raw) async {
    if (_handling) return;

    final payload = NurPayQr.tryParse(raw);
    if (payload is! StaticQr) {
      _complain('Bu Nur Pay-yň hemişelik QR kody däl');
      return;
    }

    setState(() => _handling = true);
    final cubit = context.read<TransferCubit>();
    final resolved = await cubit.resolve(payload);
    if (!mounted) return;

    if (!resolved) {
      _complain(cubit.state.error?.userMessage ?? 'Kod okalmady');
      return;
    }
    context.pushReplacement(AppRoutes.transferAmount);
  }

  void _complain(String message) {
    setState(() => _handling = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => RoleTheme.dark(
    role: AppRole.customer,
    child: Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              Positioned.fill(
                child: ScannerView(
                  accent: cs.primary,
                  active: !_handling,
                  onDetect: _onDetect,
                  hint: _handling
                      ? 'Kod okaldy…'
                      : 'Alyjynyň hemişelik QR kodyny skanirläň',
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
                    child: AppTopBar(title: 'Pul geçir'),
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
                      child: AppButton.outlined(
                        label: 'Kontaktlardan saýla',
                        icon: Icons.contacts_outlined,
                        onPressed: _handling
                            ? null
                            : () => context.push(AppRoutes.transferContacts),
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

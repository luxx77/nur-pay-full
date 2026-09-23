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
        final text = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              Positioned.fill(
                child: ScannerView(
                  accent: cs.primary,
                  active: !_handling,
                  onDetect: _onDetect,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const AppTopBar(title: 'Pul geçir'),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      child: Text(
                        _handling
                            ? 'Kod okaldy…'
                            : 'Alyjynyň hemişelik QR kodyny skanirläň',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(
                          color: _handling ? cs.primary : cs.onSurfaceVariant,
                        ),
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

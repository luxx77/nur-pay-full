import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';

/// 6.1 · Meniň QR kodum — постоянный QR.
///
/// Код не меняется и таймера не имеет: им получают деньги. Тот же экран
/// показывается агенту при пополнении — меняются только подписи.
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key, this.forAgent = false});

  /// Открыт из сценария пополнения: код показывают агенту.
  final bool forAgent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final state = context.watch<SessionCubit>().state;

    if (state is! SessionActive) return const AppScaffold(body: SizedBox());
    final session = state.session;

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          AppTopBar(
            title: forAgent ? 'Agentden doldur' : 'Meniň QR kodum',
            trailing: Text(
              'HEMIŞELIK',
              style: text.labelSmall?.copyWith(
                color: cs.onPrimaryContainer,
                letterSpacing: 0.06 * 12.sp,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              children: [
                Center(
                  child: QrBrandCard(
                    data: StaticQr(publicQrUuid: session.publicQrUuid).encode(),
                  ),
                ),
                Gap(16.h),
                Column(
                  children: [
                    Text(session.title, style: text.titleLarge),
                    if (session.phone != null) ...[
                      Gap(3.h),
                      Text(
                        session.phone!,
                        style: text.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          color: cs.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
                Gap(14.h),
                Text(
                  forAgent
                      ? 'Kody agente görkeziň. Ol puly kabul edip, '
                            'hasabyňyza geçirer.'
                      : 'Bu kod üýtgemeýär. Skrinşot alyp, islän '
                            'adamyňyza iberip bilersiňiz — size pul geçirer.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    height: 1.55,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: AppButton.filled(
              label: 'Taýýar',
              onPressed: () => forAgent
                  ? context.go(AppRoutes.home)
                  : Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

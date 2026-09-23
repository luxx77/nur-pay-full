import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/app_role.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';

/// 9.1 · Profil — свой QR, режим, связь, выход.
///
/// Режим не переключается в приложении: роль приходит с сервера, мерчанта
/// назначают в базе.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final state = context.watch<SessionCubit>().state;
    final wallet = context.watch<WalletCubit>().state;

    if (state is! SessionActive) return const AppScaffold(body: SizedBox());
    final session = state.session;

    return AppScaffold(
      padded: false,
      safeBottom: false,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
            child: Row(
              children: [
                AppAvatar.fromName(session.title, size: 60.r),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: text.titleLarge,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      if (session.phone != null)
                        Text(
                          session.phone!,
                          style: text.bodyMedium?.copyWith(
                            fontSize: 15.sp,
                            color: cs.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionLabel('Hasap'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AppListGroup(
              children: [
                AppListRow(
                  title: 'Meniň QR kodum',
                  leading: Icons.qr_code_2_rounded,
                  onTap: () => context.push(AppRoutes.myQr),
                ),
                AppListRow(
                  title: 'Režim',
                  leading: Icons.badge_outlined,
                  value: session.role.label,
                  showChevron: false,
                ),
                const AppListRow(
                  title: 'Dil',
                  leading: Icons.language_rounded,
                  value: 'Türkmen',
                  showChevron: false,
                ),
              ],
            ),
          ),
          const SectionLabel('Maglumat'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AppListGroup(
              children: [
                AppListRow(
                  title: 'Maglumatlary täzele',
                  leading: Icons.sync_rounded,
                  value: wallet.loading ? '…' : null,
                  onTap: context.read<WalletCubit>().refresh,
                ),
                const AppListRow(
                  title: 'Kömek',
                  leading: Icons.help_outline_rounded,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: AppButton.danger(
              label: 'Çyk',
              onPressed: context.read<SessionCubit>().logout,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/money.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/activation_cubit.dart';

/// 5.3 · Hasap dolduryldy — результат пополнения кодом.
class TopUpSuccessPage extends StatelessWidget {
  const TopUpSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final state = context.watch<ActivationCubit>().state;
    final balance = context.watch<WalletCubit>().state.balance;

    final topUp = state.result.where((e) => !e.isFee).firstOrNull;
    final fee = state.result.where((e) => e.isFee).firstOrNull;

    void exit() => context.go(AppRoutes.home);

    if (topUp == null) {
      return AppScaffold(
        body: EmptyState(
          title: 'Amal tapylmady',
          message: 'Doldurmak barada maglumat ýok',
          actions: [
            AppButton.filled(
              label: 'Esasy',
              size: AppButtonSize.medium,
              expanded: false,
              onPressed: exit,
            ),
          ],
        ),
      );
    }

    return FlowResult(
      onExit: exit,
      child: AppScaffold(
        padded: false,
        body: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  ResultGlyph(tone: ResultGlyphTone.successSoft, size: 76.r),
                  Gap(14.h),
                  Text(
                    'Hasap dolduryldy',
                    textAlign: TextAlign.center,
                    style: text.headlineMedium,
                  ),
                  Gap(14.h),
                  AmountText(
                    topUp.netAmount(fee).formatted,
                    sign: '+',
                    tone: AmountTone.income,
                  ),
                ],
              ),
              Gap(18.h),
              InfoBanner(
                title: 'Täze balans: ${(balance ?? Money.zero).withCurrency}',
                tone: InfoBannerTone.brand,
                showDot: false,
              ),
              Gap(14.h),
              DetailList.filled(
                rows: [
                  DetailRow('Sene', TmDate.receipt(topUp.createdAt)),
                  DetailRow('Amalyň belgisi', '#${topUp.id}', mono: true),
                ],
              ),
              const Spacer(),
              AppButton.filled(label: 'Taýýar', onPressed: exit),
            ],
          ),
        ),
      ),
    );
  }
}

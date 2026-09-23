import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/money.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../bloc/merchant_payment_cubit.dart';

/// 7.6 · Çäkden ýokary — запрошено больше, чем клиент разрешил.
///
/// Цифры берём с устройства: лимит лежит в отсканированном коде, запрос
/// набрал сам кассир. Сервер в ошибке чисел не присылает.
class MerchantLimitExceededPage extends StatelessWidget {
  const MerchantLimitExceededPage({super.key});

  @override
  Widget build(BuildContext context) => RoleTheme(
    role: AppRole.merchant,
    child: Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        final state = context.watch<MerchantPaymentCubit>().state;
        final limit = state.scanned?.maxAmount ?? Money.zero;

        Widget line(String label, Money value, {bool error = false}) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              value.withCurrency,
              style: text.titleMedium?.copyWith(
                fontSize: 19.sp,
                color: error ? cs.error : cs.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AppCard(
            radius: 28.r,
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultGlyph(tone: ResultGlyphTone.error, size: 56.r),
                Gap(14.h),
                Text('Çäkden ýokary', style: text.headlineSmall),
                Gap(14.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Column(
                    children: [
                      line('Müşderiniň çägi', limit),
                      Gap(8.h),
                      line('Siz soraýarsyňyz', state.amount, error: true),
                    ],
                  ),
                ),
                Gap(14.h),
                Text(
                  'Möçberi azaldyň ýa-da müşderiden QR kody täzeden '
                  'döretmegini soraň.',
                  style: text.bodyMedium?.copyWith(
                    height: 1.55,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Gap(16.h),
                AppButton.filled(
                  label: 'Möçberi üýtget',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

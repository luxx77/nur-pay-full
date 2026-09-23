import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../money.dart';
import '../foundation/app_radius.dart';
import '../foundation/app_shadows.dart';
import '../motion/animated_money.dart';
import 'amount_text.dart';

/// Карточка баланса.
///
/// Градиент от бренда к его тёмному тону плюс мягкое пятно света в углу:
/// карточка читается как «главный объект экрана», не крича об этом.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.amount,
    required this.caption,
    this.label = 'Balans',
    this.currency = 'TMT',
    this.stale = false,
    this.staleNote,
  });

  final Money amount;

  /// Строка над суммой: «Soňky sinhronizasiýa: şu gün 14:32».
  final String caption;

  /// Подпись под суммой.
  final String label;
  final String currency;

  /// Данные могли устареть — рядом с подписью появляется точка.
  final bool stale;
  final String? staleNote;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onPrimary.withValues(alpha: 0.72);

    return _BrandSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stale) ...[
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7.w),
              ],
              Flexible(
                child: Text(
                  caption,
                  style: text.bodySmall?.copyWith(color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          AnimatedMoney(
            value: amount,
            builder: (context, value) => AmountText(
              value.formatted,
              currency: currency,
              tone: AmountTone.onBrand,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            staleNote ?? label,
            style: text.bodySmall?.copyWith(fontSize: 13.5.sp, color: muted),
          ),
        ],
      ),
    );
  }
}

/// Карточка дневной выручки: сумма и две метрики.
class RevenueCard extends StatelessWidget {
  const RevenueCard({
    super.key,
    required this.amount,
    required this.caption,
    required this.metrics,
    this.currency = 'TMT',
  });

  final Money amount;
  final String caption;

  /// Пары «подпись → значение» в нижней строке карточки.
  final List<(String, String)> metrics;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onPrimary.withValues(alpha: 0.72);

    return _BrandSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: text.bodySmall?.copyWith(fontSize: 13.5.sp, color: muted),
          ),
          SizedBox(height: 4.h),
          AnimatedMoney(
            value: amount,
            builder: (context, value) => AmountText(
              value.formatted,
              currency: currency,
              tone: AmountTone.onBrand,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.only(top: 14.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: cs.onPrimary.withValues(alpha: 0.18)),
              ),
            ),
            child: Row(
              children: [
                for (final (label, value) in metrics)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: text.bodySmall?.copyWith(color: muted),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          value,
                          style: text.titleLarge?.copyWith(
                            color: cs.onPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Брендовая поверхность с градиентом и бликом.
class _BrandSurface extends StatelessWidget {
  const _BrandSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadius.xxl);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.brandCard(cs.primary),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary,
                Color.lerp(cs.primary, cs.onPrimaryContainer, 0.65)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Блик уводит взгляд к сумме и снимает плоскость заливки.
              Positioned(
                right: -40.w,
                top: -60.h,
                child: Container(
                  width: 190.r,
                  height: 190.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cs.onPrimary.withValues(alpha: 0.14),
                        cs.onPrimary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(22.w), child: child),
            ],
          ),
        ),
      ),
    );
  }
}

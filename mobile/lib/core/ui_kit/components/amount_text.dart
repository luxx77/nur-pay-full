import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Тон суммы: приход — зелёный, ожидание — янтарный, расход — обычный.
enum AmountTone { neutral, income, pending, brand, onBrand, error }

/// Размер крупной суммы.
enum AmountSize {
  /// 72 pt — экран результата у мерчанта.
  hero,

  /// 56 pt — ввод суммы.
  display,

  /// 48 pt — баланс и подтверждение.
  large,

  /// 24 pt — компактная сводка в шапке сканера.
  compact,
}

/// Крупная сумма с отдельной подписью валюты: «248,50 TMT».
class AmountText extends StatelessWidget {
  const AmountText(
    this.amount, {
    super.key,
    this.currency = 'TMT',
    this.size = AmountSize.large,
    this.tone = AmountTone.neutral,
    this.sign,
  });

  final String amount;
  final String currency;
  final AmountSize size;
  final AmountTone tone;

  /// Необязательный знак перед суммой: `'+'` или `'−'`.
  final String? sign;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final color = switch (tone) {
      AmountTone.neutral => cs.onSurface,
      AmountTone.income => cs.onSecondaryContainer,
      AmountTone.pending => cs.onTertiaryContainer,
      AmountTone.brand => cs.onPrimaryContainer,
      AmountTone.onBrand => cs.onPrimary,
      AmountTone.error => cs.error,
    };
    final currencyColor = switch (tone) {
      AmountTone.onBrand => cs.onPrimary.withValues(alpha: 0.75),
      _ => cs.onSurfaceVariant,
    };

    final (
      TextStyle? amountStyle,
      double currencySize,
      double gap,
    ) = switch (size) {
      AmountSize.hero => (text.displayLarge, 26.sp, 10.w),
      AmountSize.display => (text.displayMedium, 22.sp, 8.w),
      AmountSize.large => (text.displaySmall, 20.sp, 8.w),
      AmountSize.compact => (
        text.titleLarge?.copyWith(fontSize: 21.sp, letterSpacing: -0.4),
        13.sp,
        5.w,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          sign == null ? amount : '$sign$amount',
          style: amountStyle?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(width: gap),
        Text(
          currency,
          style: text.titleLarge?.copyWith(
            fontSize: currencySize,
            fontWeight: FontWeight.w500,
            color: currencyColor,
          ),
        ),
      ],
    );
  }
}

/// Сумма в строке списка: «+120,00» / «−48,50».
class AmountLabel extends StatelessWidget {
  const AmountLabel(
    this.amount, {
    super.key,
    this.tone = AmountTone.neutral,
    this.fontSize,
  });

  final String amount;
  final AmountTone tone;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (tone) {
      AmountTone.neutral => cs.onSurface,
      AmountTone.income => cs.onSecondaryContainer,
      AmountTone.pending => cs.onTertiaryContainer,
      AmountTone.brand => cs.onPrimaryContainer,
      AmountTone.onBrand => cs.onPrimary,
      AmountTone.error => cs.error,
    };

    return Text(
      amount,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: fontSize ?? 17.sp,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

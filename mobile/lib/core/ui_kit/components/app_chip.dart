import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Кругленький чип выбора: быстрые суммы (20 · 50 · 100) и периоды фильтра.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.tabular = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Табличные цифры — для сумм.
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    var style = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontSize: 15.sp,
      color: selected ? cs.onPrimaryContainer : cs.onSurface,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    );
    if (tabular && style != null) {
      style = style.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );
    }

    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
      borderRadius: AppRadius.pillAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: selected ? null : Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }
}

/// Небольшая кнопка-пилюля в шапке: «Süzgüç».
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onTap;

  /// Серый вариант — когда фильтровать нечего.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: muted ? cs.surfaceContainerHighest : cs.primaryContainer,
      borderRadius: AppRadius.pillAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: muted ? cs.outline : cs.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

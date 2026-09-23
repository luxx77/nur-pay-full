import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Смысловой тон бейджа.
enum AppStatusTone {
  /// Успех, «онлайн», «Geçirildi».
  success,

  /// Ожидание подтверждения, офлайн-очередь.
  pending,

  /// Нет сети, нейтральное состояние.
  neutral,

  /// Бренд: «Söwda nokady», «BIR GEZEKLIK».
  brand,

  /// Ошибка.
  error,
}

/// Бейдж состояния: точка + подпись на мягкой подложке.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.showDot = true,
    this.uppercase = false,
    this.square = false,
  });

  final String label;
  final AppStatusTone tone;
  final bool showDot;

  /// Разрядка и верхний регистр — для меток вроде «BIR GEZEKLIK».
  final bool uppercase;

  /// Слегка скруглённый прямоугольник вместо «таблетки».
  final bool square;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (Color bg, Color fg, Color dot) = switch (tone) {
      AppStatusTone.success => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        cs.secondary,
      ),
      AppStatusTone.pending => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        cs.tertiary,
      ),
      AppStatusTone.neutral => (
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
        cs.outline,
      ),
      AppStatusTone.brand => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        cs.primary,
      ),
      AppStatusTone.error => (cs.errorContainer, cs.onErrorContainer, cs.error),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: square ? AppRadius.smAll : AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: uppercase ? 12.sp : 13.sp,
              color: fg,
              letterSpacing: uppercase ? 0.06 * 12.sp : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../foundation/app_shadows.dart';
import '../motion/app_motion.dart';
import '../motion/pressable.dart';

/// Визуальные варианты кнопки.
enum AppButtonVariant {
  /// Заливка брендом — главное действие экрана.
  filled,

  /// Мягкая подложка бренда — второе по важности действие.
  tonal,

  /// Нейтральная серая заливка.
  neutral,

  /// Поверхность с рамкой — «Ýatyr», «Surata al».
  outlined,

  /// Поверхность с брендовой рамкой и текстом — «Yzyna gaýtar».
  brandOutlined,

  /// Рамка и текст цветом ошибки — «Çyk».
  danger,

  /// Без фона — текстовое действие.
  text,
}

enum AppButtonSize { small, medium, large }

/// Кнопка Nur Pay.
///
/// Под нажатием слегка проседает — это и есть основной отклик; у главной
/// кнопки есть мягкая тень её же цветом.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  });

  const AppButton.filled({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.filled;

  const AppButton.tonal({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.neutral({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.neutral;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.brandOutlined({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.brandOutlined;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.expanded = true,
    this.loading = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  bool get _enabled => onPressed != null && !loading;

  double get _height => switch (size) {
    AppButtonSize.small => 44.h,
    AppButtonSize.medium => 52.h,
    AppButtonSize.large => 58.h,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(
      size == AppButtonSize.small ? AppRadius.md : AppRadius.lg,
    );

    final (Color bg, Color fg, Color? border) = switch (variant) {
      AppButtonVariant.filled => (cs.primary, cs.onPrimary, null),
      AppButtonVariant.tonal => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        null,
      ),
      AppButtonVariant.neutral => (
        cs.surfaceContainerHighest,
        cs.onSurface,
        null,
      ),
      AppButtonVariant.outlined => (
        cs.surfaceBright,
        cs.onSurface,
        cs.outlineVariant,
      ),
      AppButtonVariant.brandOutlined => (
        cs.surfaceBright,
        cs.onPrimaryContainer,
        cs.primaryFixedDim,
      ),
      AppButtonVariant.danger => (
        cs.surfaceBright,
        cs.error,
        cs.errorContainer,
      ),
      AppButtonVariant.text => (Colors.transparent, cs.primary, null),
    };

    final background = _enabled ? bg : cs.surfaceDim;
    final foreground = _enabled ? fg : cs.onSurface.withValues(alpha: 0.38);

    final style =
        (size == AppButtonSize.large ? text.labelLarge : text.titleSmall)
            ?.copyWith(color: foreground);

    return Pressable(
      onTap: onPressed,
      enabled: _enabled,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.enter,
        height: _height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: border != null && _enabled
              ? Border.all(color: border, width: 1.5)
              : null,
          boxShadow: _enabled && variant == AppButtonVariant.filled
              ? AppShadows.brand(cs.primary)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            splashColor: foreground.withValues(alpha: 0.08),
            highlightColor: foreground.withValues(alpha: 0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 16.w : 24.w),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading) ...[
                    SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 20.r, color: foreground),
                    SizedBox(width: 10.w),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

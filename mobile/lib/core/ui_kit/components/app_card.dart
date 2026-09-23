import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../foundation/app_shadows.dart';
import '../motion/app_motion.dart';
import '../motion/pressable.dart';

/// Карточка контента.
///
/// По умолчанию поднята мягкой тенью, а не обведена рамкой: так блоки
/// отделяются от фона, не добавляя экрану линий.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.borderColor,
    this.elevated = true,
    this.clip = false,
    this.onTap,
  });

  /// Карточка-список: содержимое режется по радиусу, внутренних полей нет.
  const AppCard.list({super.key, required this.child, this.radius})
    : padding = EdgeInsets.zero,
      color = null,
      borderColor = null,
      elevated = true,
      clip = true,
      onTap = null;

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;

  /// Рамка вместо тени.
  final Color? borderColor;

  final bool elevated;
  final bool clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(radius ?? AppRadius.xl);
    final bordered = borderColor != null;

    final body = Padding(
      padding: padding ?? EdgeInsets.all(16.w),
      child: child,
    );

    // Тень живёт на внешнем слое, внутренний клипует содержимое.
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? cs.surface,
        borderRadius: borderRadius,
        border: bordered ? Border.all(color: borderColor!) : null,
      ),
      child: clip ? ClipRRect(borderRadius: borderRadius, child: body) : body,
    );

    if (elevated) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: AppShadows.soft(cs.shadow),
        ),
        child: card,
      );
    }

    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.985, child: card);
  }
}

/// Карточка выбора с крупной иконкой — «Usuly saýlaň», «Režim».
class AppSelectableCard extends StatelessWidget {
  const AppSelectableCard({
    super.key,
    required this.title,
    required this.description,
    required this.leading,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String description;

  /// Значок слева: `Text('##')`, `Icon(...)` — что угодно.
  final Widget leading;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = AppRadius.xlAll;

    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.enter,
        decoration: BoxDecoration(
          color: selected ? cs.primaryFixedDim : cs.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1.5,
          ),
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.quick,
                  curve: AppMotion.enter,
                  width: 46.r,
                  height: 46.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      size: 22.r,
                      color: selected ? cs.onPrimary : cs.onSurface,
                    ),
                    child: DefaultTextStyle(
                      style:
                          text.titleSmall?.copyWith(
                            color: selected ? cs.onPrimary : cs.onSurface,
                          ) ??
                          const TextStyle(),
                      child: leading,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Text(title, style: text.titleMedium)),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 22.r,
                    color: cs.primary,
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              description,
              style: text.bodyMedium?.copyWith(
                fontSize: 14.5.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

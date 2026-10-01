import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../foundation/app_shadows.dart';

/// Квадратная плавающая кнопка 64×64 — главное действие экрана.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.child,
    this.onPressed,
    this.size,
    this.outlined = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double? size;

  /// Белая с рамкой вместо брендовой заливки — «Çeki paýlaş».
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 64.r;
    final radius = BorderRadius.circular(side * 0.31);
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: !enabled
            ? null
            : outlined
            ? AppShadows.raised(cs.shadow)
            : AppShadows.fab(cs.primary),
      ),
      child: Material(
        color: !enabled
            ? cs.surfaceDim
            : outlined
            ? cs.surface
            : cs.primary,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            width: side,
            height: side,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: outlined
                  ? Border.all(color: cs.outlineVariant, width: 1.5)
                  : null,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: !enabled
                    ? cs.onSurface.withValues(alpha: 0.38)
                    : outlined
                    ? cs.onPrimaryContainer
                    : cs.onPrimary,
                size: side * 0.44,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Растянутая плавающая кнопка с подписью — «Dükanda töle».
class AppExtendedFab extends StatelessWidget {
  const AppExtendedFab({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.onLongPress,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xxlAll,
        boxShadow: AppShadows.fab(cs.primary),
      ),
      child: Material(
        color: cs.primary,
        borderRadius: AppRadius.xxlAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: SizedBox(
              height: 64.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: cs.onPrimary, size: 30.r),
                    child: icon,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: cs.onPrimary),
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

/// Дополнительное действие speed-dial: белая пилюля с иконкой и подписью.
class SpeedDialAction extends StatelessWidget {
  const SpeedDialAction({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: enabled ? AppShadows.raised(cs.shadow) : null,
      ),
      child: Material(
        color: enabled ? cs.surface : cs.surfaceDim,
        borderRadius: AppRadius.xlAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: AppRadius.xlAll,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: enabled
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: enabled
                            ? cs.onPrimaryContainer
                            : cs.onSurface.withValues(alpha: 0.38),
                        size: 14.r,
                      ),
                      child: icon ?? const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 15.sp,
                      color: enabled
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.38),
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

/// Колонка speed-dial: дополнительные действия над главной кнопкой.
///
/// При сворачивании действия уезжают вниз под главную кнопку и гаснут.
class SpeedDial extends StatelessWidget {
  const SpeedDial({
    super.key,
    required this.actions,
    required this.primary,
    this.expanded = true,
  });

  final List<Widget> actions;
  final Widget primary;
  final bool expanded;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      for (final (index, action) in actions.indexed)
        AnimatedSlide(
          duration: Duration(milliseconds: 220 + index * 40),
          curve: Curves.easeOutCubic,
          offset: expanded
              ? Offset.zero
              : Offset(0, 1.4 * (actions.length - index)),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: expanded ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: IgnorePointer(ignoring: !expanded, child: action),
            ),
          ),
        ),
      primary,
    ],
  );
}

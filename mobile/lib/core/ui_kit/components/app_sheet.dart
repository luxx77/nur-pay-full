import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../foundation/app_shadows.dart';
import 'brand_mark.dart';

/// Шторка снизу: ручка, содержимое, скруглённый верх.
///
/// Используется и как модальное окно (`AppSheet.show`), и как статичный
/// элемент внутри экрана-макета.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.action,
    this.padding,
    this.showHandle = true,
  });

  final Widget child;

  /// Заголовок шторки — всегда по центру.
  final String? title;

  /// Текстовое действие справа от заголовка («Arassala»).
  final Widget? action;

  final EdgeInsetsGeometry? padding;
  final bool showHandle;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.34),
    builder: (_) => AppSheet(title: title, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.sheetTop,
        boxShadow: AppShadows.sheet(cs.shadow),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: AppRadius.sheetTop,
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: padding ?? EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showHandle) ...[
                  const SheetHandle(),
                  SizedBox(height: 16.h),
                ],
                if (title != null) ...[
                  _SheetTitle(title: title!, action: action),
                  SizedBox(height: 16.h),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 28.h,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
          softWrap: false,
        ),
        if (action != null)
          Align(alignment: Alignment.centerRight, child: action!),
      ],
    ),
  );
}

/// Затемнение под шторкой или диалогом.
class AppScrim extends StatelessWidget {
  const AppScrim({super.key, this.child, this.onTap});

  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: cs.scrim.withValues(alpha: 0.34),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}

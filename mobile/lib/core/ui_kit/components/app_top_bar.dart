import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Шапка внутреннего экрана: «‹» и заголовок слева, действие справа.
///
/// Заголовок получает всю свободную ширину — его не должно резать
/// многоточием.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.center,
    this.showBack = true,
  });

  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// Элемент по центру шапки — например бейдж «BIR GEZEKLIK».
  /// Взаимоисключён с [title].
  final Widget? center;

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final back = showBack
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                CupertinoIcons.chevron_back,
                size: 22.r,
                color: cs.onSurfaceVariant,
              ),
            ),
          )
        : const SizedBox.shrink();

    // Центрированный вариант: по краям равные отступы, чтобы элемент
    // стоял ровно посередине независимо от ширины кнопок.
    if (center != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        child: SizedBox(
          height: 36.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: back),
              center!,
              if (trailing != null)
                Align(alignment: Alignment.centerRight, child: trailing!),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: SizedBox(
        height: 36.h,
        child: Row(
          children: [
            back,
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  style: text.titleMedium,
                  maxLines: 1,
                  softWrap: false,
                ),
              )
            else
              const Spacer(),
            if (trailing != null) ...[SizedBox(width: 12.w), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Крупный заголовок раздела: «Taryh» + действие справа.
class AppLargeTitleBar extends StatelessWidget {
  const AppLargeTitleBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

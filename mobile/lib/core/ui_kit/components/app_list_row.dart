import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../motion/pressable.dart';
import 'app_card.dart';

/// Строка настроек с шевроном и необязательным значением справа.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.value,
    this.leading,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? value;
  final IconData? leading;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        child: Row(
          children: [
            if (leading != null) ...[
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(leading, size: 18.r, color: cs.onSurfaceVariant),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                title,
                style: text.bodyLarge?.copyWith(color: cs.onSurface),
                maxLines: 1,
                softWrap: false,
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: text.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  color: cs.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            if (showChevron) ...[
              SizedBox(width: 8.w),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 15.r,
                color: cs.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Группа строк настроек — приподнятая карточка с внутренними линейками.
class AppListGroup extends StatelessWidget {
  const AppListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = <Widget>[];
    for (final (index, child) in children.indexed) {
      rows.add(child);
      if (index != children.length - 1) {
        rows.add(Divider(color: cs.outlineVariant, height: 1, indent: 16.w));
      }
    }

    return AppCard.list(child: Column(children: rows));
  }
}

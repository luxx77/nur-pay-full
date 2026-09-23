import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Капслочная подпись-разделитель над группой строк: «SOŇKYLAR», «ŞU GÜN».
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: cs.outline,
          letterSpacing: 0.08 * 12.sp,
        ),
      ),
    );
  }
}

/// Заголовок блока внутри экрана: «Soňky amallar».
class BlockTitle extends StatelessWidget {
  const BlockTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 17.sp),
  );
}

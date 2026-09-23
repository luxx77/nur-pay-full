import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_palette.dart';
import '../foundation/app_radius.dart';

/// Знак Nur Pay: скруглённый квадрат бренда с жёлтой точкой внутри.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 28.r;

    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(side * 0.29),
      ),
      child: Container(
        width: side * 0.36,
        height: side * 0.36,
        decoration: const BoxDecoration(
          color: AppPalette.logoDot,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Знак с названием — левая часть шапки главного экрана.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, required this.title, this.markSize});

  final String title;
  final double? markSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      BrandMark(size: markSize),
      SizedBox(width: 9.w),
      Flexible(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontSize: 17.sp),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// Ручка шторки.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 44.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: AppRadius.pillAll,
      ),
    ),
  );
}

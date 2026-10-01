import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Знак Nur Pay: иконка приложения (`assets/icon/nur_pay_icon.png`).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final side = size ?? 28.r;

    return Image.asset(
      'assets/icon/nur_pay_icon.png',
      width: side,
      height: side,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Сегментированный переключатель: «Hemmesi · Gelen · Giden».
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    this.onChanged,
    this.compact = false,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onChanged == null ? null : () => onChanged!(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(vertical: compact ? 9.h : 10.h),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    segments[i],
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: i == selectedIndex
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

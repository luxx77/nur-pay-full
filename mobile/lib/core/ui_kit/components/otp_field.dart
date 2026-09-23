import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Ячейки SMS-кода. Активная клетка подсвечивается кольцом бренда.
class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.value,
    this.length = 4,
    this.error = false,
  });

  /// Уже введённые цифры.
  final String value;
  final int length;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = error ? cs.error : cs.primary;

    return Row(
      children: [
        for (var i = 0; i < length; i++) ...[
          Expanded(
            child: Container(
              height: 68.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: i == value.length ? accent : cs.outlineVariant,
                  width: i == value.length ? 2 : 1.5,
                ),
                boxShadow: i == value.length
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.12),
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                i < value.length ? value[i] : '',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28.sp,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          if (i != length - 1) SizedBox(width: 10.w),
        ],
      ],
    );
  }
}

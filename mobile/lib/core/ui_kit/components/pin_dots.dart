import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Точки введённого PIN-кода.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.filled,
    this.length = 4,
    this.error = false,
  });

  /// Сколько цифр уже введено.
  final int filled;
  final int length;

  /// Ошибочный PIN — точки краснеют.
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = error ? cs.error : cs.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 18.r,
            height: 18.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? active : Colors.transparent,
              border: i < filled
                  ? null
                  : Border.all(color: cs.outlineVariant, width: 2),
            ),
          ),
          if (i != length - 1) SizedBox(width: 16.w),
        ],
      ],
    );
  }
}

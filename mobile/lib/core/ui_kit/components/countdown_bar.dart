import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Срок жизни одноразового QR: подпись, счётчик и полоса прогресса.
class CountdownBar extends StatelessWidget {
  const CountdownBar({
    super.key,
    required this.label,
    required this.remaining,
    required this.progress,
  });

  final String label;

  /// Готовая строка вида «0:54».
  final String remaining;

  /// Доля оставшегося времени, 0…1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final low = progress < 0.25;
    final accent = low ? cs.error : cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              remaining,
              style: text.headlineSmall?.copyWith(
                color: accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: AppRadius.pillAll,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6.h,
            backgroundColor: cs.outlineVariant,
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
      ],
    );
  }
}

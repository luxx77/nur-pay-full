import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Тон информационной плашки.
enum InfoBannerTone {
  /// Серая — состояние сети.
  neutral,

  /// Янтарная — очередь операций.
  pending,

  /// Янтарная пунктирная — пояснение к «зависшей» операции.
  pendingOutlined,

  /// Брендовая — подсказка в сценарии.
  brand,
}

/// Плашка-пояснение с точкой слева.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.tone = InfoBannerTone.neutral,
    this.showDot = true,
  });

  final String title;
  final String? subtitle;
  final InfoBannerTone tone;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final (Color bg, Color fg, Color dot, Color? border) = switch (tone) {
      InfoBannerTone.neutral => (
        cs.surfaceContainerHighest,
        cs.onSurface,
        cs.outline,
        null,
      ),
      InfoBannerTone.pending => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        cs.tertiary,
        null,
      ),
      InfoBannerTone.pendingOutlined => (
        cs.tertiaryFixedDim,
        cs.onTertiaryContainer,
        cs.tertiary,
        cs.tertiary,
      ),
      InfoBannerTone.brand => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        cs.primary,
        null,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: border == null
            ? null
            : Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDot) ...[
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: subtitle == null
                      ? text.bodyMedium?.copyWith(fontSize: 14.sp, color: fg)
                      : text.titleSmall?.copyWith(fontSize: 15.sp, color: fg),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: text.bodySmall?.copyWith(
                      color: tone == InfoBannerTone.neutral
                          ? cs.onSurfaceVariant
                          : fg.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Пояснение на янтарной подложке без точки — «Töleg kabul edildi…».
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cs.tertiaryFixedDim,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.55)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(height: 1.55, color: cs.onTertiaryContainer),
      ),
    );
  }
}

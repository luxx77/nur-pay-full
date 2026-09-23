import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Квадратная иконка-кнопка в шапке (QR клиента, меню мерчанта).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tonal = false,
    this.size,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// `true` — подложка `primaryContainer`, `false` — белая с рамкой.
  final bool tonal;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 40.r;

    return Material(
      color: tonal ? cs.primaryContainer : cs.surface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          width: side,
          height: side,
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: tonal ? null : Border.all(color: cs.outlineVariant),
          ),
          child: Icon(
            icon,
            size: side * 0.5,
            color: tonal ? cs.onPrimaryContainer : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

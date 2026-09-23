import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Тон аватара: бренд — для «своих» контактов, нейтральный — для остальных.
enum AppAvatarTone { brand, neutral, success, pending }

/// Круглый аватар с инициалами или иконкой.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.initials,
    this.icon,
    this.size,
    this.tone = AppAvatarTone.brand,
  }) : assert(initials != null || icon != null, 'нужны инициалы или иконка');

  /// Инициалы из имени: «Merdan Ataýew» → «MA».
  factory AppAvatar.fromName(
    String name, {
    Key? key,
    double? size,
    AppAvatarTone tone = AppAvatarTone.brand,
  }) {
    final parts = name
        .replaceAll(RegExp(r'[«»"]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2);
    final initials = parts.map((w) => w.substring(0, 1).toUpperCase()).join();
    return AppAvatar(key: key, initials: initials, size: size, tone: tone);
  }

  final String? initials;
  final IconData? icon;
  final double? size;
  final AppAvatarTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 44.r;

    final (Color bg, Color fg) = switch (tone) {
      AppAvatarTone.brand => (cs.primaryContainer, cs.onPrimaryContainer),
      AppAvatarTone.neutral => (cs.surfaceContainerHighest, cs.onSurface),
      AppAvatarTone.success => (cs.secondaryContainer, cs.onSecondaryContainer),
      AppAvatarTone.pending => (cs.tertiaryContainer, cs.onTertiaryContainer),
    };

    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: icon != null
          ? Icon(icon, size: side * 0.48, color: fg)
          : Text(
              initials!,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontSize: side * 0.38, color: fg),
            ),
    );
  }
}

import 'package:flutter/widgets.dart';

/// Тени.
///
/// Двухслойные: короткая задаёт край, длинная — высоту. Один слой всегда
/// выглядит либо грязно, либо плоско.
abstract final class AppShadows {
  /// Едва заметный подъём — карточки контента.
  static List<BoxShadow> soft(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.05),
      blurRadius: 24,
      spreadRadius: -6,
      offset: const Offset(0, 8),
    ),
  ];

  /// Заметный подъём — всплывающие панели, диалоги.
  static List<BoxShadow> raised(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.12),
      blurRadius: 32,
      spreadRadius: -8,
      offset: const Offset(0, 12),
    ),
  ];

  /// Плавающая кнопка светится своим цветом.
  ///
  /// Большой отрицательный разлёт при большом размытии — иначе тень
  /// ложится под элемент плотной полосой, а не рассеянным светом.
  static List<BoxShadow> fab(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.26),
      blurRadius: 34,
      spreadRadius: -12,
      offset: const Offset(0, 14),
    ),
  ];

  /// Брендовая карточка: мягкое свечение своим цветом.
  static List<BoxShadow> brandCard(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.18),
      blurRadius: 40,
      spreadRadius: -16,
      offset: const Offset(0, 16),
    ),
  ];

  /// Цветная тень под главной кнопкой.
  static List<BoxShadow> brand(Color tint) => [
    BoxShadow(
      color: tint.withValues(alpha: 0.2),
      blurRadius: 24,
      spreadRadius: -10,
      offset: const Offset(0, 10),
    ),
  ];

  /// Шторка снизу.
  static List<BoxShadow> sheet(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.18),
      blurRadius: 40,
      spreadRadius: -8,
      offset: const Offset(0, -12),
    ),
  ];
}

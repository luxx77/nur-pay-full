import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Шрифтовая шкала Nur Pay.
///
/// Размеры взяты из макета (база 402 × 874) и масштабируются ScreenUtil.
/// Суммы и любые цифры набираются моноширинными «табличными» цифрами —
/// для этого есть [AppTypography.tabular].
abstract final class AppTypography {
  static const sans = 'IBMPlexSans';
  static const mono = 'IBMPlexMono';

  static const _tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

  /// Табличные цифры: ширина знака не скачет при пересчёте суммы.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: _tabularFigures);

  /// Моноширинный стиль для ID операций и кодов активации.
  static TextStyle monospace(TextStyle style) =>
      style.copyWith(fontFamily: mono, fontFeatures: _tabularFigures);

  static TextTheme textTheme(Color onSurface) {
    TextStyle s(double size, FontWeight weight, {double? height, double? ls}) =>
        TextStyle(
          fontFamily: sans,
          fontSize: size.sp,
          fontWeight: weight,
          height: height,
          letterSpacing: ls == null ? null : ls * size.sp,
          color: onSurface,
        );

    return TextTheme(
      // Крупные суммы на экранах результата и ввода.
      displayLarge: s(72, FontWeight.w600, height: 1, ls: -0.04),
      displayMedium: s(56, FontWeight.w600, height: 1.05, ls: -0.04),
      displaySmall: s(48, FontWeight.w600, height: 1.1, ls: -0.035),
      // Заголовки экранов.
      headlineLarge: s(28, FontWeight.w600, height: 1.2),
      headlineMedium: s(26, FontWeight.w600, height: 1.25),
      headlineSmall: s(22, FontWeight.w600, height: 1.25),
      // Заголовки блоков и строк списка.
      titleLarge: s(20, FontWeight.w600, height: 1.3),
      titleMedium: s(18, FontWeight.w600, height: 1.3),
      titleSmall: s(16, FontWeight.w600, height: 1.35),
      // Текст.
      bodyLarge: s(17, FontWeight.w400, height: 1.45),
      bodyMedium: s(15, FontWeight.w400, height: 1.5),
      bodySmall: s(13, FontWeight.w400, height: 1.45),
      // Подписи, бейджи, кнопки.
      labelLarge: s(17, FontWeight.w600, height: 1.2),
      labelMedium: s(14, FontWeight.w600, height: 1.3),
      labelSmall: s(12, FontWeight.w600, height: 1.3, ls: 0.02),
    );
  }
}

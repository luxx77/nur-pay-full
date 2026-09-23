import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui_kit/foundation/app_radius.dart';
import '../ui_kit/motion/page_transition.dart';
import 'app_color_schemes.dart';
import '../app_role.dart';
import 'app_typography.dart';

/// Сборка [ThemeData] поверх [ColorScheme].
///
/// Тема строится из роли ([AppRole]) и яркости — больше ничего снаружи
/// задавать не нужно. Виджеты читают цвета только из `theme.colorScheme`.
abstract final class AppTheme {
  /// Один и тот же переход на всех платформах — движение должно быть
  /// частью продукта, а не настройкой системы.
  static final _pageTransitions = PageTransitionsTheme(
    builders: {
      for (final platform in TargetPlatform.values)
        platform: const AppPageTransitionsBuilder(),
    },
  );

  /// Размер макета — iPhone 16 Pro (402 × 874).
  static const designSize = Size(402, 874);

  static ThemeData of(
    AppRole role, [
    Brightness brightness = Brightness.light,
  ]) => _build(AppColorSchemes.of(role, brightness));

  static ThemeData light(AppRole role) => of(role, Brightness.light);

  static ThemeData dark(AppRole role) => of(role, Brightness.dark);

  static ThemeData _build(ColorScheme cs) {
    final textTheme = AppTypography.textTheme(cs.onSurface);
    final isLight = cs.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: cs.brightness,
      fontFamily: AppTypography.sans,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surfaceContainerLow,
      canvasColor: cs.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surfaceContainerLow,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cs.surface,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 22.r),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
      ),
      splashColor: cs.primary.withValues(alpha: 0.08),
      highlightColor: cs.primary.withValues(alpha: 0.04),
      pageTransitionsTheme: _pageTransitions,
    );
  }
}

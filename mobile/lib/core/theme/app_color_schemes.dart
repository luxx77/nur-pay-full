import 'package:flutter/material.dart';

import 'app_palette.dart';
import '../app_role.dart';

/// Цветовые схемы приложения.
///
/// Роли Material 3 переиспользованы под смысл продукта:
///
/// | роль                  | смысл в Nur Pay                                   |
/// |-----------------------|---------------------------------------------------|
/// | `primary`             | бренд: синий у клиента, зелёный у мерчанта        |
/// | `primaryContainer`    | мягкая подложка бренда (чипы, tonal-кнопки)       |
/// | `secondary`           | успех, входящие деньги, статус «онлайн»           |
/// | `tertiary`            | ожидание, офлайн-очередь (янтарный)               |
/// | `error`               | отказ, превышение лимита, выход                   |
/// | `surface`             | карточки и панели (белый)                         |
/// | `surfaceContainerLow` | фон экрана (с лёгким оттенком бренда)             |
/// | `surfaceContainerHigh`| клавиши цифровой клавиатуры                       |
/// | `outline`             | вторичный текст-подсказка, неактивные иконки      |
/// | `outlineVariant`      | разделители и светлые границы                     |
/// | `inverseSurface`      | тёмный фон сканера                                |
abstract final class AppColorSchemes {
  static ColorScheme of(AppRole role, Brightness brightness) =>
      switch ((role, brightness)) {
        (AppRole.customer, Brightness.light) => customerLight,
        (AppRole.customer, Brightness.dark) => customerDark,
        (AppRole.merchant, Brightness.light) => merchantLight,
        (AppRole.merchant, Brightness.dark) => merchantDark,
      };

  // ── Клиент · светлая ──────────────────────────────────────────────────────
  static const customerLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.blue,
    onPrimary: AppPalette.white,
    primaryContainer: AppPalette.blueContainer,
    onPrimaryContainer: AppPalette.blueDark,
    primaryFixedDim: AppPalette.blueSoft,
    secondary: AppPalette.success,
    onSecondary: AppPalette.white,
    secondaryContainer: AppPalette.successContainer,
    onSecondaryContainer: AppPalette.onSuccessContainer,
    tertiary: AppPalette.warning,
    onTertiary: AppPalette.white,
    tertiaryContainer: AppPalette.warningContainer,
    onTertiaryContainer: AppPalette.onWarningContainer,
    tertiaryFixedDim: AppPalette.warningSurface,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.errorDark,
    surface: AppPalette.white,
    onSurface: AppPalette.ink,
    onSurfaceVariant: AppPalette.inkMuted,
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: AppPalette.blueBg,
    surfaceContainer: AppPalette.blueField,
    surfaceContainerHigh: AppPalette.blueKeypad,
    surfaceContainerHighest: AppPalette.neutral95,
    surfaceDim: AppPalette.neutral95,
    surfaceBright: AppPalette.white,
    outline: AppPalette.inkFaint,
    outlineVariant: AppPalette.hairline,
    shadow: AppPalette.ink,
    scrim: AppPalette.scrim,
    inverseSurface: AppPalette.darkBg,
    onInverseSurface: AppPalette.white,
    inversePrimary: AppPalette.blueOnDark,
    surfaceTint: AppPalette.blue,
  );

  // ── Мерчант · светлая ─────────────────────────────────────────────────────
  static const merchantLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.green,
    onPrimary: AppPalette.white,
    primaryContainer: AppPalette.greenContainer,
    onPrimaryContainer: AppPalette.greenDark,
    primaryFixedDim: AppPalette.greenBorder,
    secondary: AppPalette.success,
    onSecondary: AppPalette.white,
    secondaryContainer: AppPalette.successContainer,
    onSecondaryContainer: AppPalette.onSuccessContainer,
    tertiary: AppPalette.warning,
    onTertiary: AppPalette.white,
    tertiaryContainer: AppPalette.warningContainer,
    onTertiaryContainer: AppPalette.onWarningContainer,
    tertiaryFixedDim: AppPalette.warningSurface,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.errorDark,
    surface: AppPalette.white,
    onSurface: AppPalette.ink,
    onSurfaceVariant: AppPalette.inkMuted,
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: AppPalette.greenBg,
    surfaceContainer: AppPalette.greenField,
    surfaceContainerHigh: AppPalette.greenKeypad,
    surfaceContainerHighest: AppPalette.neutral95,
    surfaceDim: AppPalette.neutral95,
    surfaceBright: AppPalette.white,
    outline: AppPalette.inkFaint,
    outlineVariant: AppPalette.hairline,
    shadow: AppPalette.ink,
    scrim: AppPalette.scrim,
    inverseSurface: AppPalette.darkBg,
    onInverseSurface: AppPalette.white,
    inversePrimary: AppPalette.greenOnDark,
    surfaceTint: AppPalette.green,
  );

  // ── Тёмная (сканер и полноэкранные оверлеи) ───────────────────────────────
  static const customerDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.blueOnDark,
    onPrimary: AppPalette.blueDark,
    primaryContainer: AppPalette.blueDark,
    onPrimaryContainer: AppPalette.blueContainer,
    primaryFixedDim: AppPalette.darkSurfaceHigh,
    secondary: AppPalette.successBright,
    onSecondary: AppPalette.onSuccessContainer,
    secondaryContainer: AppPalette.onSuccessContainer,
    onSecondaryContainer: AppPalette.successContainer,
    tertiary: AppPalette.warningBorder,
    onTertiary: AppPalette.onWarningContainer,
    tertiaryContainer: AppPalette.onWarningContainer,
    onTertiaryContainer: AppPalette.warningContainer,
    tertiaryFixedDim: AppPalette.darkSurfaceHigh,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorDark,
    onErrorContainer: AppPalette.errorContainer,
    surface: AppPalette.darkBg,
    onSurface: AppPalette.white,
    onSurfaceVariant: AppPalette.neutral80,
    surfaceContainerLowest: AppPalette.darkBg,
    surfaceContainerLow: AppPalette.darkBg,
    surfaceContainer: AppPalette.darkSurface,
    surfaceContainerHigh: AppPalette.darkSurfaceHigh,
    surfaceContainerHighest: AppPalette.darkSurfaceHigh,
    surfaceDim: AppPalette.darkBg,
    surfaceBright: AppPalette.darkSurfaceHigh,
    outline: AppPalette.darkInkFaint,
    outlineVariant: AppPalette.darkOutline,
    shadow: Color(0xFF000000),
    scrim: AppPalette.scrim,
    inverseSurface: AppPalette.white,
    onInverseSurface: AppPalette.ink,
    inversePrimary: AppPalette.blue,
    surfaceTint: AppPalette.blueOnDark,
  );

  static const merchantDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.greenOnDark,
    onPrimary: AppPalette.greenDark,
    primaryContainer: AppPalette.greenDark,
    onPrimaryContainer: AppPalette.greenContainer,
    primaryFixedDim: AppPalette.darkSurfaceHigh,
    secondary: AppPalette.success,
    onSecondary: AppPalette.white,
    secondaryContainer: AppPalette.onSuccessContainer,
    onSecondaryContainer: AppPalette.successBright,
    tertiary: AppPalette.warningBorder,
    onTertiary: AppPalette.onWarningContainer,
    tertiaryContainer: AppPalette.onWarningContainer,
    onTertiaryContainer: AppPalette.warningContainer,
    tertiaryFixedDim: AppPalette.darkSurfaceHigh,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorDark,
    onErrorContainer: AppPalette.errorContainer,
    surface: AppPalette.darkBg,
    onSurface: AppPalette.white,
    onSurfaceVariant: AppPalette.neutral80,
    surfaceContainerLowest: AppPalette.darkBg,
    surfaceContainerLow: AppPalette.darkBg,
    surfaceContainer: AppPalette.darkSurface,
    surfaceContainerHigh: AppPalette.darkSurfaceHigh,
    surfaceContainerHighest: AppPalette.darkSurfaceHigh,
    surfaceDim: AppPalette.darkBg,
    surfaceBright: AppPalette.darkSurfaceHigh,
    outline: AppPalette.darkInkFaint,
    outlineVariant: AppPalette.darkOutline,
    shadow: Color(0xFF000000),
    scrim: AppPalette.scrim,
    inverseSurface: AppPalette.white,
    onInverseSurface: AppPalette.ink,
    inversePrimary: AppPalette.green,
    surfaceTint: AppPalette.greenOnDark,
  );
}

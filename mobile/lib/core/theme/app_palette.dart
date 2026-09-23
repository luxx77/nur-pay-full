import 'package:flutter/material.dart';

/// Сырые цветовые токены из макета (`Nur Pay — Screens`).
///
/// Этот класс — единственное место, где живут hex-значения.
/// В UI цвета брать **только** через `Theme.of(context).colorScheme`.
/// Исходники в макете заданы в oklch, здесь переведены в sRGB.
abstract final class AppPalette {
  // ── Бренд · клиент (синий) ────────────────────────────────────────────────
  static const blue = Color(0xFF004F94); // oklch(0.42 0.14 248)
  static const blueDark = Color(0xFF003972); // oklch(0.34 0.12 248)
  static const blueContainer = Color(0xFFD6EBFF); // oklch(0.93 0.035 248)
  static const blueSoft = Color(0xFFEDF6FF); // oklch(0.97 0.016 248)
  static const blueOnDark = Color(0xFFBDD4EB); // oklch(0.86 0.04 248)
  static const blueBg = Color(0xFFF8FAFD); // oklch(0.985 0.005 248)
  static const blueField = Color(0xFFF1F5F8); // oklch(0.968 0.006 248)
  static const blueKeypad = Color(0xFFEFF3F7); // oklch(0.962 0.007 248)

  // ── Бренд · мерчант (зелёный) ─────────────────────────────────────────────
  static const green = Color(0xFF00583A); // oklch(0.40 0.10 165)
  static const greenDark = Color(0xFF003E24); // oklch(0.31 0.09 165)
  static const greenContainer = Color(0xFFD3F0E2); // oklch(0.93 0.035 165)
  static const greenBorder = Color(0xFFB7DBCA); // oklch(0.86 0.045 165)
  static const greenOnDark = Color(0xFFC3DFD2); // oklch(0.88 0.035 165)
  static const greenBg = Color(0xFFF7FBF9); // oklch(0.985 0.005 165)
  static const greenField = Color(0xFFF1F6F3); // oklch(0.968 0.006 165)
  static const greenKeypad = Color(0xFFEEF4F1); // oklch(0.962 0.007 165)

  // ── Успех / входящие деньги ───────────────────────────────────────────────
  static const success = Color(0xFF137D41); // oklch(0.52 0.13 152)
  static const successContainer = Color(0xFFDCF7E2); // oklch(0.95 0.04 152)
  static const onSuccessContainer = Color(0xFF005827); // oklch(0.40 0.11 152)
  static const successBright = Color(0xFF69D98D); // oklch(0.80 0.15 152)

  // ── Ожидание / офлайн-очередь (янтарный) ──────────────────────────────────
  static const warning = Color(0xFFA97416); // oklch(0.60 0.12 75)
  static const warningContainer = Color(0xFFFFEECF); // oklch(0.955 0.045 80)
  static const onWarningContainer = Color(0xFF784900); // oklch(0.45 0.10 70)
  static const warningSurface = Color(0xFFFFFBF3); // oklch(0.99 0.012 85)
  static const warningBorder = Color(0xFFD0A66C); // oklch(0.75 0.09 75)

  // ── Ошибка ────────────────────────────────────────────────────────────────
  static const error = Color(0xFFC22826); // oklch(0.53 0.19 27)
  static const errorDark = Color(0xFF9E1618); // oklch(0.45 0.17 27)
  static const errorContainer = Color(0xFFFFE9E5); // oklch(0.955 0.03 27)

  // ── Нейтральные ───────────────────────────────────────────────────────────
  static const ink = Color(0xFF151B21); // oklch(0.22 0.015 250)
  static const inkMuted = Color(0xFF565B61); // oklch(0.47 0.012 250)
  static const inkFaint = Color(0xFF858A8F); // oklch(0.63 0.01 250)
  static const hairline = Color(0xFFDBDEE2); // oklch(0.90 0.006 250)
  static const divider = Color(0xFFE5E8EC); // oklch(0.93 0.006 250)
  static const neutral95 = Color(0xFFEBEFF2); // oklch(0.95 0.006 250)
  static const neutral80 = Color(0xFFB9BEC4); // oklch(0.80 0.01 250)
  static const white = Color(0xFFFFFFFF);

  // ── Тёмные поверхности (сканер, шторки) ───────────────────────────────────
  static const darkBg = Color(0xFF12171B); // oklch(0.20 0.012 250)
  static const darkSurface = Color(0xFF20252A); // oklch(0.26 0.012 250)
  static const darkSurfaceHigh = Color(0xFF292E34); // oklch(0.30 0.012 250)
  static const darkOutline = Color(0xFF484E54); // oklch(0.42 0.012 250)
  static const darkInkFaint = Color(0xFF83878B); // oklch(0.62 0.008 250)
  static const scrim = Color(0xFF1D2022); // oklch(0.24 0.006 250)

  /// Жёлтая точка в логотипе — не роль темы, а часть знака.
  static const logoDot = Color(0xFFF4E8BB); // oklch(0.93 0.06 95)
}

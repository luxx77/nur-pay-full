import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../motion/pressable.dart';

/// Какая клавиша стоит слева от нуля.
enum KeypadLayout {
  /// Пусто — PIN, SMS-код, код активации.
  plain,

  /// Запятая — ввод суммы.
  decimal,
}

/// Цифровая клавиатура приложения.
///
/// Используется на вводе суммы, PIN, кода активации — везде одна и та же,
/// меняется только высота клавиш и наличие запятой.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKey,
    required this.onBackspace,
    this.layout = KeypadLayout.plain,
    this.keyHeight,
    this.onBackspaceLongPress,
  });

  /// Приходит один символ: «0»…«9» или «,».
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  /// Долгое нажатие на ⌫ — очистить поле.
  final VoidCallback? onBackspaceLongPress;
  final KeypadLayout layout;
  final double? keyHeight;

  @override
  Widget build(BuildContext context) {
    final height = keyHeight ?? 66.h;

    Widget key(String label) =>
        _KeypadKey(label: label, height: height, onTap: () => onKey(label));

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                for (final k in row) ...[
                  Expanded(child: key(k)),
                  if (k != row.last) SizedBox(width: 8.w),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: layout == KeypadLayout.decimal
                  ? key(',')
                  : SizedBox(height: height),
            ),
            SizedBox(width: 8.w),
            Expanded(child: key('0')),
            SizedBox(width: 8.w),
            Expanded(
              child: _KeypadKey(
                height: height,
                onTap: onBackspace,
                onLongPress: onBackspaceLongPress,
                muted: true,
                child: Icon(CupertinoIcons.delete_left, size: 24.r),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.height,
    required this.onTap,
    this.label,
    this.child,
    this.muted = false,
    this.onLongPress,
  });

  final double height;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? label;
  final Widget? child;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      scale: 0.94,
      child: Material(
        color: muted ? cs.surfaceContainerHighest : cs.surfaceContainerHigh,
        borderRadius: AppRadius.mdAll,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Center(
            child: child != null
                ? IconTheme(
                    data: IconThemeData(color: cs.onSurface),
                    child: child!,
                  )
                : Text(
                    label!,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: height * 0.41,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

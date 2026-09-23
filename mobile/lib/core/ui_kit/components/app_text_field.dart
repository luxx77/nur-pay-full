import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Текстовое поле Nur Pay: рамка 1.5 px, активная — брендовая с кольцом.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.prefix,
    this.suffix,
    this.filled = false,
    this.textAlign = TextAlign.start,
    this.height,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool autofocus;
  final Widget? prefix;
  final Widget? suffix;

  /// Серая заливка вместо белой — поле поиска.
  final bool filled;
  final TextAlign textAlign;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height ?? 52.h,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            readOnly: readOnly,
            autofocus: autofocus,
            textAlign: textAlign,
            cursorColor: cs.primary,
            style: text.bodyLarge?.copyWith(fontSize: 16.sp),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: text.bodyLarge?.copyWith(
                fontSize: 16.sp,
                color: cs.outline,
              ),
              filled: true,
              fillColor: filled ? cs.surfaceContainer : cs.surface,
              prefixIcon: prefix,
              suffixIcon: suffix,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: _border(cs.outlineVariant),
              enabledBorder: _border(cs.outlineVariant),
              focusedBorder: _border(cs.primary, width: 2),
              errorBorder: _border(cs.error, width: 2),
              focusedErrorBorder: _border(cs.error, width: 2),
            ),
          ),
        ),
        if (helper != null || errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            errorText ?? helper!,
            style: text.bodySmall?.copyWith(
              fontSize: 13.5.sp,
              color: errorText != null ? cs.error : cs.outline,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: color, width: width),
      );
}

/// Поле поиска контактов.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    hint: hint,
    filled: true,
    autofocus: autofocus,
    onChanged: onChanged,
  );
}

/// Группирует цифры номера парами: «65 12 34 56».
class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter({this.maxDigits = 8});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .characters
        .take(maxDigits)
        .toString();

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i.isEven) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Поле телефона: несменяемый код страны слева и разбитый на пары номер.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    this.controller,
    this.countryCode = '+993',
    this.helper,
    this.onChanged,
    this.autofocus = true,
  });

  final TextEditingController? controller;
  final String countryCode;
  final String? helper;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final numberStyle = text.titleLarge?.copyWith(
      fontSize: 19.sp,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 0.03 * 19.sp,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56.h,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: autofocus,
            keyboardType: TextInputType.phone,
            inputFormatters: const [PhoneNumberFormatter()],
            cursorColor: cs.primary,
            style: numberStyle,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: cs.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 16.h,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 14.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: cs.outlineVariant)),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    countryCode,
                    style: numberStyle?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minHeight: 56.h),
              border: _phoneBorder(cs.outlineVariant),
              enabledBorder: _phoneBorder(cs.outlineVariant),
              focusedBorder: _phoneBorder(cs.primary),
            ),
          ),
        ),
        if (helper != null) ...[
          SizedBox(height: 8.h),
          Text(
            helper!,
            style: text.bodySmall?.copyWith(
              fontSize: 13.5.sp,
              color: cs.outline,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _phoneBorder(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.smAll,
    borderSide: BorderSide(color: color, width: 1.5),
  );
}

/// Поле-«витрина»: значение отображается, ввод идёт с клавиатуры приложения.
class DisplayField extends StatelessWidget {
  const DisplayField({
    super.key,
    required this.child,
    this.focused = false,
    this.height,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final bool focused;
  final double? height;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: height ?? 64.h,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: focused ? cs.primary : cs.outlineVariant,
          width: focused ? 2 : 1.5,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.12),
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Пара полей «от — до» для фильтра.
class RangeFields extends StatelessWidget {
  const RangeFields({super.key, required this.from, required this.to});

  final Widget from;
  final Widget to;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: from),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            '—',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: cs.outline),
          ),
        ),
        Expanded(child: to),
      ],
    );
  }
}

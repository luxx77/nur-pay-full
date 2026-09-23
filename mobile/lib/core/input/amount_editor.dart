import 'package:flutter/foundation.dart';

import '../money.dart';

/// Состояние ввода суммы с приложенческой клавиатуры.
///
/// Правила как в макете: одна запятая, не больше двух знаков после неё,
/// целая часть — до семи цифр.
class AmountEditor extends ChangeNotifier {
  AmountEditor({Money initial = Money.zero})
    : _raw = initial.isZero ? '' : _rawFrom(initial);

  static const _maxWholeDigits = 7;
  static const _maxFractionDigits = 2;

  String _raw;

  static String _rawFrom(Money value) {
    final whole = value.minor ~/ 100;
    final fraction = value.minor % 100;
    return fraction == 0
        ? '$whole'
        : '$whole,${fraction.toString().padLeft(2, '0')}';
  }

  Money get value => Money.parse(_raw);

  bool get isEmpty => _raw.isEmpty;

  /// Что показывать на экране: пусто трактуем как «0».
  String get display {
    if (_raw.isEmpty) return '0';
    final parts = _raw.split(',');
    final grouped = StringBuffer();
    final whole = parts.first.isEmpty ? '0' : parts.first;
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(' ');
      grouped.write(whole[i]);
    }
    return parts.length == 1 ? '$grouped' : '$grouped,${parts[1]}';
  }

  void push(String key) {
    if (key == ',') {
      if (_raw.contains(',')) return;
      _raw = _raw.isEmpty ? '0,' : '$_raw,';
      notifyListeners();
      return;
    }

    final parts = _raw.split(',');
    if (parts.length == 2) {
      if (parts[1].length >= _maxFractionDigits) return;
    } else {
      if (parts.first.length >= _maxWholeDigits) return;
      // Лидирующий ноль заменяем, а не наращиваем.
      if (_raw == '0') _raw = '';
    }
    _raw += key;
    notifyListeners();
  }

  void backspace() {
    if (_raw.isEmpty) return;
    _raw = _raw.substring(0, _raw.length - 1);
    notifyListeners();
  }

  void clear() {
    if (_raw.isEmpty) return;
    _raw = '';
    notifyListeners();
  }

  void setValue(Money amount) {
    _raw = amount.isZero ? '' : _rawFrom(amount);
    notifyListeners();
  }
}

/// Состояние ввода кода фиксированной длины: PIN, SMS, код активации.
class DigitsEditor extends ChangeNotifier {
  DigitsEditor({required this.length, String initial = ''}) : _digits = initial;

  final int length;
  String _digits;

  String get digits => _digits;
  int get filled => _digits.length;
  bool get isComplete => _digits.length == length;

  /// Группами по четыре: «4820 7315 1129».
  String get grouped {
    final buffer = StringBuffer();
    for (var i = 0; i < _digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(_digits[i]);
    }
    return buffer.toString();
  }

  void push(String key) {
    if (_digits.length >= length) return;
    _digits += key;
    notifyListeners();
  }

  void backspace() {
    if (_digits.isEmpty) return;
    _digits = _digits.substring(0, _digits.length - 1);
    notifyListeners();
  }

  void clear() {
    if (_digits.isEmpty) return;
    _digits = '';
    notifyListeners();
  }
}

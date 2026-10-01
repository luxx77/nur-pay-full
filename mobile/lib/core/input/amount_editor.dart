import 'package:flutter/foundation.dart';

import '../money.dart';

/// Состояние ввода суммы с приложенческой клавиатуры.
///
/// Ввод — в теňňe, как на кассовых терминалах: каждая нажатая цифра
/// становится новым младшим разрядом, а запятая перед последними двумя
/// цифрами фиксирована и никогда не набирается руками. Чтобы перевести
/// 1 манат (100 теňňe), набирают «1», «0», «0» подряд — и только тогда
/// сумма встаёт на место: 100 теňňe = 1,00 TMT.
class AmountEditor extends ChangeNotifier {
  AmountEditor({Money initial = Money.zero}) : _minor = initial.minor;

  // Целая часть (манаты) — не больше семи цифр, как в макете.
  static const _maxWholeDigits = 7;

  int _minor;

  Money get value => Money(_minor);

  bool get isEmpty => _minor == 0;

  /// Что показывать на экране: пусто — «00,00», дальше как обычная сумма.
  String get display => _minor == 0 ? '00,00' : Money(_minor).formatted;

  void push(String key) {
    final digit = int.tryParse(key);
    // Запятая больше не набирается: разделитель фиксирован клавиатурой.
    if (digit == null) return;

    final next = _minor * 10 + digit;
    if ((next ~/ 100).toString().length > _maxWholeDigits) return;

    _minor = next;
    notifyListeners();
  }

  void backspace() {
    if (_minor == 0) return;
    _minor ~/= 10;
    notifyListeners();
  }

  void clear() {
    if (_minor == 0) return;
    _minor = 0;
    notifyListeners();
  }

  void setValue(Money amount) {
    _minor = amount.minor;
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

/// Сумма в манатах, хранится в тенне (1 TMT = 100 teňňe).
///
/// Целые числа вместо `double`: на деньгах округление плавающей точки
/// даёт расхождения уже на третьей операции.
extension type const Money(int minor) implements Object {
  static const zero = Money(0);
  static const currency = 'TMT';

  factory Money.major(num value) => Money((value * 100).round());

  /// Разбирает то, что набрано на клавиатуре: «48,5», «1 240,00».
  factory Money.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s ]'), '');
    if (cleaned.isEmpty) return zero;
    final parts = cleaned.split(',');
    final whole = int.tryParse(parts.first) ?? 0;
    if (parts.length == 1) return Money(whole * 100);
    final fraction = parts[1].padRight(2, '0').substring(0, 2);
    return Money(whole * 100 + (int.tryParse(fraction) ?? 0));
  }

  Money operator +(Money other) => Money(minor + other.minor);
  Money operator -(Money other) => Money(minor - other.minor);
  bool operator >(Money other) => minor > other.minor;
  bool operator <(Money other) => minor < other.minor;
  bool operator >=(Money other) => minor >= other.minor;

  bool get isZero => minor == 0;
  bool get isPositive => minor > 0;

  /// «1 240,00» — пробел между тысячами, запятая перед копейками.
  String get formatted {
    final sign = minor < 0 ? '−' : '';
    final abs = minor.abs();
    final whole = (abs ~/ 100).toString();
    final fraction = (abs % 100).toString().padLeft(2, '0');

    final grouped = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(' ');
      grouped.write(whole[i]);
    }
    return '$sign$grouped,$fraction';
  }

  /// «+120,00» / «−48,50» — как в строке истории.
  String signed({required bool incoming}) =>
      '${incoming ? '+' : '−'}${Money(minor.abs()).formatted}';

  String get withCurrency => '$formatted $currency';
}

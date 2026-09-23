/// Форматирование дат по-туркменски.
abstract final class TmDate {
  static const months = [
    'ýanwar',
    'fewral',
    'mart',
    'aprel',
    'maý',
    'iýun',
    'iýul',
    'awgust',
    'sentýabr',
    'oktýabr',
    'noýabr',
    'dekabr',
  ];

  static String two(int value) => value.toString().padLeft(2, '0');

  static String time(DateTime value) =>
      '${two(value.hour)}:${two(value.minute)}';

  static String relativeTime(DateTime value) {
    final now = DateTime.now();
    final days = _dayDiff(now, value);
    return switch (days) {
      0 => time(value),
      1 => 'düýn ${time(value)}',
      _ => '${value.day} ${months[value.month - 1]}, ${time(value)}',
    };
  }

  /// Заголовок группы в истории: «Şu gün», «Düýn», «19 sentýabr».
  static String dayHeader(DateTime value) {
    final days = _dayDiff(DateTime.now(), value);
    return switch (days) {
      0 => 'Şu gün',
      1 => 'Düýn',
      _ => '${value.day} ${months[value.month - 1]}',
    };
  }

  static String receipt(DateTime value) =>
      '${two(value.day)}.${two(value.month)}.${value.year} · ${time(value)}';

  static int _dayDiff(DateTime now, DateTime other) => DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(other.year, other.month, other.day)).inDays;
}

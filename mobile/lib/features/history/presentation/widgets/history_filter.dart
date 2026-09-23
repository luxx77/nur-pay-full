import '../../../../core/money.dart';
import '../../../wallet/domain/entities/operation.dart';

/// Настройки фильтра истории.
///
/// Фильтрация местная: сервер отдаёт список проводок, отбор по периоду и
/// сумме делается на устройстве.
class HistoryFilter {
  const HistoryFilter({this.direction = 0, this.period, this.min, this.max});

  /// 0 — все, 1 — только приход, 2 — только расход.
  final int direction;

  /// 0 — сегодня, 1 — семь дней, 2 — месяц. `null` — без ограничения.
  final int? period;

  final Money? min;
  final Money? max;

  static const periodDays = [1, 7, 30];

  bool get isActive => period != null || min != null || max != null;

  HistoryFilter copyWith({
    int? direction,
    int? period,
    Money? min,
    Money? max,
    bool resetPeriod = false,
    bool resetRange = false,
  }) => HistoryFilter(
    direction: direction ?? this.direction,
    period: resetPeriod ? null : (period ?? this.period),
    min: resetRange ? null : (min ?? this.min),
    max: resetRange ? null : (max ?? this.max),
  );

  List<Operation> apply(List<Operation> operations) {
    final since = period == null
        ? null
        : DateTime.now().subtract(Duration(days: periodDays[period!]));

    return operations.where((operation) {
      if (direction == 1 && !operation.isIncoming) return false;
      if (direction == 2 && operation.isIncoming) return false;
      if (since != null && operation.createdAt.isBefore(since)) return false;
      if (min != null && operation.amount < min!) return false;
      if (max != null && max!.isPositive && operation.amount > max!) {
        return false;
      }
      return true;
    }).toList();
  }
}

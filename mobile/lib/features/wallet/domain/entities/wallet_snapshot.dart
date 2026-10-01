import '../../../../core/money.dart';
import 'operation.dart';

/// Баланс и история на момент последнего успешного чтения.
///
/// Приходит либо прямо с бэкенда, либо — когда сети нет — из локального
/// кеша: в обоих случаях экран показывает одно и то же, разница только в
/// [isStale].
class WalletSnapshot {
  const WalletSnapshot({
    required this.balance,
    required this.operations,
    required this.updatedAt,
    required this.isStale,
  });

  final Money balance;
  final List<Operation> operations;

  /// Когда эти данные были получены с сервера (не когда отрисован экран).
  final DateTime updatedAt;

  /// `true` — сеть сейчас недоступна, это сохранённый ранее снимок.
  final bool isStale;
}

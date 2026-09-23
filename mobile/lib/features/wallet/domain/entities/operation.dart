import '../../../../core/money.dart';

/// Что за операция. Совпадает со значениями `type` в ledger.
enum OperationType {
  activation('activation', 'Işjeňleşdirme kody'),
  p2p('p2p', 'Geçirim'),
  merchantPayment('merchant_payment', 'Söwda'),
  fee('fee', 'Komissiýa');

  const OperationType(this.api, this.label);

  final String api;
  final String label;

  static OperationType fromApi(String value) =>
      values.firstWhere((t) => t.api == value, orElse: () => p2p);
}

/// Куда двигались деньги относительно того, кто смотрит.
enum OperationDirection {
  incoming('in'),
  outgoing('out');

  const OperationDirection(this.api);

  final String api;

  static OperationDirection fromApi(String value) =>
      value == 'in' ? incoming : outgoing;
}

/// Вторая сторона операции.
class Counterparty {
  const Counterparty({
    required this.userId,
    required this.isMerchant,
    this.displayName,
    this.phone,
  });

  final String userId;
  final bool isMerchant;
  final String? displayName;
  final String? phone;

  /// Как назвать сторону в интерфейсе.
  String get title => displayName ?? phone ?? 'Nur Pay';
}

/// Проводка из книги. Приложение их только читает — меняет только бэкенд.
class Operation {
  const Operation({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.counterparty,
    required this.createdAt,
    this.parentId,
  });

  final int id;
  final OperationType type;
  final OperationDirection direction;
  final Money amount;
  final Counterparty counterparty;
  final DateTime createdAt;

  /// У комиссии ссылается на основную проводку.
  final int? parentId;

  bool get isIncoming => direction == OperationDirection.incoming;
  bool get isFee => type == OperationType.fee;

  /// «+120,00» / «−48,50».
  String get signedAmount => amount.signed(incoming: isIncoming);
}

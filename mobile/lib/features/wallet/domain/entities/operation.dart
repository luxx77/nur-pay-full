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
    this.isSystem = false,
    this.displayName,
    this.phone,
  });

  final String userId;
  final bool isMerchant;

  /// Системный счёт (выпуск денег, комиссии): имени для людей у него нет,
  /// в display_name лежит служебное «issuance».
  final bool isSystem;
  final String? displayName;
  final String? phone;

  /// Как назвать сторону в интерфейсе.
  String get title => isSystem ? 'Nur Pay' : displayName ?? phone ?? 'Nur Pay';
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

  /// Сумма за вычетом комиссии — то, что фактически увидел пользователь
  /// на балансе. Комиссию как отдельную строку не показываем.
  Money netAmount(Operation? fee) => fee == null ? amount : amount - fee.amount;
}

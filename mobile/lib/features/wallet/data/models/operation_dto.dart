import '../../../../core/money.dart';
import '../../domain/entities/operation.dart';

/// Разбор проводки из ответа API.
abstract final class OperationDto {
  static Operation fromJson(Map<String, dynamic> json) {
    final cp = json['counterparty'] as Map<String, dynamic>;
    return Operation(
      id: json['id'] as int,
      type: OperationType.fromApi(json['type'] as String),
      direction: OperationDirection.fromApi(json['direction'] as String),
      amount: Money(json['amount'] as int),
      parentId: json['parent_id'] as int?,
      counterparty: Counterparty(
        userId: cp['user_id'] as String,
        isMerchant: cp['user_type'] == 'merchant',
        displayName: cp['display_name'] as String?,
        phone: cp['phone'] as String?,
      ),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Ответы с операциями всегда приходят списком `entries`.
  static List<Operation> listFrom(Map<String, dynamic> json) =>
      (json['entries'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
}

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
        isSystem: cp['user_type'] == 'system',
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

  /// Тот же формат, что и ответ API — чтобы [fromJson] годился и для
  /// локального кеша.
  static Map<String, dynamic> toJson(Operation operation) => {
    'id': operation.id,
    'type': operation.type.api,
    'direction': operation.direction.api,
    'amount': operation.amount.minor,
    'parent_id': operation.parentId,
    'created_at': operation.createdAt.toIso8601String(),
    'counterparty': {
      'user_id': operation.counterparty.userId,
      'user_type': operation.counterparty.isMerchant
          ? 'merchant'
          : operation.counterparty.isSystem
          ? 'system'
          : 'user',
      'display_name': operation.counterparty.displayName,
      'phone': operation.counterparty.phone,
    },
  };
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/money.dart';
import '../../domain/entities/operation.dart';
import '../models/operation_dto.dart';

/// Последний снимок кошелька, сохранённый на устройстве.
///
/// Единственная задача — пережить открытие приложения без сети: баланс и
/// история не секрет, поэтому обычные настройки, а не secure storage.
class WalletLocalDataSource {
  const WalletLocalDataSource();

  static const _balanceKey = 'wallet.cache.balance';
  static const _operationsKey = 'wallet.cache.operations';
  static const _updatedAtKey = 'wallet.cache.updated_at';

  Future<void> save({
    required Money balance,
    required List<Operation> operations,
    required DateTime updatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, balance.minor);
    await prefs.setString(
      _operationsKey,
      jsonEncode(operations.map(OperationDto.toJson).toList()),
    );
    await prefs.setString(_updatedAtKey, updatedAt.toIso8601String());
  }

  Future<WalletCacheEntry?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final balanceMinor = prefs.getInt(_balanceKey);
    final updatedAtRaw = prefs.getString(_updatedAtKey);
    if (balanceMinor == null || updatedAtRaw == null) return null;

    final operationsRaw = prefs.getString(_operationsKey);
    final operations = operationsRaw == null
        ? const <Operation>[]
        : (jsonDecode(operationsRaw) as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(OperationDto.fromJson)
              .toList();

    return WalletCacheEntry(
      balance: Money(balanceMinor),
      operations: operations,
      updatedAt: DateTime.parse(updatedAtRaw),
    );
  }
}

class WalletCacheEntry {
  const WalletCacheEntry({
    required this.balance,
    required this.operations,
    required this.updatedAt,
  });

  final Money balance;
  final List<Operation> operations;
  final DateTime updatedAt;
}

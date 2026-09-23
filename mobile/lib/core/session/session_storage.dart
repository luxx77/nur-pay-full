import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';

/// Хранилище сессии на устройстве.
///
/// Защищённое, а не обычные настройки: внутри лежит `payment_secret`,
/// которым подписываются платёжные коды.
class SessionStorage {
  const SessionStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'nurpay.session';

  final FlutterSecureStorage _storage;

  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      // Хранилище повреждено — считаем, что сессии нет.
      await clear();
      return null;
    }
  }

  Future<void> write(Session session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  Future<void> clear() => _storage.delete(key: _key);
}

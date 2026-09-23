import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN живёт только на устройстве.
///
/// У бэкенда его нет: это локальный замок перед подтверждением операции,
/// а не второй фактор на сервере.
class PinStorage {
  const PinStorage([this._storage = const FlutterSecureStorage()]);

  static const length = 4;
  static const _key = 'nurpay.pin';

  final FlutterSecureStorage _storage;

  Future<bool> get isSet async => await _storage.read(key: _key) != null;

  Future<bool> verify(String pin) async =>
      await _storage.read(key: _key) == pin;

  Future<void> save(String pin) => _storage.write(key: _key, value: pin);

  Future<void> clear() => _storage.delete(key: _key);
}

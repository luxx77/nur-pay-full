import '../../../../core/session/session.dart';

/// Вход и хранение сессии.
abstract interface class AuthRepository {
  /// Сессия с прошлого запуска, если она была.
  Future<Session?> restore();

  /// Вход по номеру телефона. Без OTP — так задумано в прототипе.
  Future<Session> login(String phone);

  Future<void> logout();
}

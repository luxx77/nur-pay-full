import '../../../../core/app_role.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session.dart';
import '../../../../core/session/session_storage.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._client, this._storage);

  final ApiClient _client;
  final SessionStorage _storage;

  @override
  Future<Session?> restore() async {
    final session = await _storage.read();
    // Клиент должен знать сессию раньше первого запроса: заголовки
    // авторизации берутся из неё.
    _client.session = session;
    return session;
  }

  @override
  Future<Session> login(String phone) async {
    final json = await _client.post('/auth/login', body: {'phone': phone});

    final session = Session(
      userId: json['user_id'] as String,
      role: appRoleFromApi(json['user_type'] as String),
      publicQrUuid: json['public_qr_uuid'] as String,
      paymentSecret: json['payment_secret'] as String,
      phone: json['phone'] as String?,
      displayName: json['display_name'] as String?,
    );

    _client.session = session;
    await _storage.write(session);
    return session;
  }

  @override
  Future<void> logout() async {
    _client.session = null;
    await _storage.clear();
  }
}

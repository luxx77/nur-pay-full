import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_role.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/session/pin_storage.dart';
import '../../../../core/session/session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Состояние входа.
sealed class SessionState {
  const SessionState();
}

/// Сессию ещё не прочитали с устройства.
class SessionUnknown extends SessionState {
  const SessionUnknown();
}

class SessionAbsent extends SessionState {
  const SessionAbsent();
}

class SessionActive extends SessionState {
  const SessionActive(this.session, {required this.pinSet});

  final Session session;

  /// PIN создан — можно подтверждать операции.
  final bool pinSet;

  AppRole get role => session.role;
}

/// Кто вошёл и под какой ролью.
///
/// Роль приходит с сервера и в приложении не меняется: мерчанта назначают
/// в базе.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._auth, this._pins) : super(const SessionUnknown());

  final AuthRepository _auth;

  final PinStorage _pins;

  Future<void> restore() async {
    final session = await _auth.restore();
    if (session == null) {
      emit(const SessionAbsent());
      return;
    }
    emit(SessionActive(session, pinSet: await _pins.isSet));
  }

  /// Вход по номеру. Ошибка уходит наверх — её показывает экран.
  Future<void> login(String phone) async {
    final session = await _auth.login(phone);
    emit(SessionActive(session, pinSet: await _pins.isSet));
  }

  Future<void> setPin(String pin) async {
    await _pins.save(pin);
    final current = state;
    if (current is SessionActive) {
      emit(SessionActive(current.session, pinSet: true));
    }
  }

  Future<bool> verifyPin(String pin) => _pins.verify(pin);

  Future<void> logout() async {
    await _auth.logout();
    await _pins.clear();
    emit(const SessionAbsent());
  }

  /// Сервер не признал заголовки — сессия больше не действительна.
  Future<void> handleAuthFailure(ApiException error) async {
    if (error.requiresLogout) await logout();
  }
}

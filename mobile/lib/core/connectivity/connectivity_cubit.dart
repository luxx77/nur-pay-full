import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Есть ли у устройства сетевой интерфейс (вайфай/мобильная связь).
///
/// Это не то же самое, что доступность бэкенда: сеть может быть подключена,
/// но без выхода в интернет — это по-прежнему ловит `ApiException.isNetwork`
/// после неудачного запроса. Кубит нужен, чтобы узнавать про обрыв/возврат
/// связи сразу, а не только после следующей попытки сходить на сервер.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(true) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    emit(_isOnline(initial));
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => emit(_isOnline(results)),
    );
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

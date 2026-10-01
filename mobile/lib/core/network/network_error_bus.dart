import 'dart:async';

import 'api_exception.dart';

/// Сетевые сбои на всё приложение.
///
/// [ApiClient] пишет сюда при каждом обрыве связи — не только тот экран,
/// что делал запрос, вправе показать сообщение об этом. Слушатель один,
/// у корня дерева виджетов: см. `NetworkErrorToast`.
class NetworkErrorBus {
  NetworkErrorBus._();

  static final NetworkErrorBus instance = NetworkErrorBus._();

  final _controller = StreamController<ApiException>.broadcast();

  Stream<ApiException> get stream => _controller.stream;

  void add(ApiException error) => _controller.add(error);
}

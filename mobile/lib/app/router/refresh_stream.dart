import 'dart:async';

import 'package:flutter/foundation.dart';

/// Мостик между потоком состояния и go_router.
///
/// Роутеру нужен `Listenable`, кубиту удобнее поток — эта обёртка
/// переводит одно в другое.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

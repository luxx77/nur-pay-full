import 'dart:async';

import 'package:flutter/material.dart';

import 'network_error_bus.dart';

/// Вешается в `MaterialApp.builder` — выше любой страницы, но внутри
/// того же `ScaffoldMessenger`, что и они. Слушает [NetworkErrorBus] и
/// показывает тост при обрыве связи, где бы он ни случился: в фоновом
/// обновлении баланса или в экране перевода.
class NetworkErrorToast extends StatefulWidget {
  const NetworkErrorToast({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkErrorToast> createState() => _NetworkErrorToastState();
}

class _NetworkErrorToastState extends State<NetworkErrorToast> {
  // Без сети запросы (баланс, история, ретраи) валятся один за другим —
  // не заваливаем экран одинаковыми тостами.
  static const _minGap = Duration(seconds: 5);

  late final StreamSubscription<void> _subscription;
  DateTime? _lastShownAt;

  @override
  void initState() {
    super.initState();
    _subscription = NetworkErrorBus.instance.stream.listen((error) {
      if (!mounted) return;
      final now = DateTime.now();
      if (_lastShownAt != null && now.difference(_lastShownAt!) < _minGap) {
        return;
      }
      _lastShownAt = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.userMessage)));
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

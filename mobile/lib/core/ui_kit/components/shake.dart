import 'dart:math';

import 'package:flutter/widgets.dart';

/// Встряхивает содержимое при каждом изменении [trigger].
///
/// Используется на неверном PIN: движение читается быстрее, чем текст.
class Shake extends StatefulWidget {
  const Shake({
    super.key,
    required this.trigger,
    required this.child,
    this.distance = 10,
  });

  /// Любое меняющееся значение — например счётчик неудачных попыток.
  final int trigger;
  final Widget child;
  final double distance;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger != 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, child) {
      final t = _controller.value;
      final offset = sin(t * pi * 4) * widget.distance * (1 - t);
      return Transform.translate(offset: Offset(offset, 0), child: child);
    },
    child: widget.child,
  );
}

import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Появление элемента: всплывает снизу и проявляется.
///
/// [index] задаёт лесенку в списках — соседние блоки приходят один за
/// другим. Задержка встроена в кривую, а не в таймер: анимация одна,
/// и она всегда доигрывает до конца.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 16,
    this.stagger = const Duration(milliseconds: 55),
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration stagger;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = widget.stagger * widget.index;

  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium + _delay,
  )..forward();

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _delay.inMicroseconds / _controller.duration!.inMicroseconds,
      1,
      curve: AppMotion.enter,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (_, child) => Opacity(
      opacity: _progress.value,
      child: Transform.translate(
        offset: Offset(0, widget.offset * (1 - _progress.value)),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

/// Раскладывает детей лесенкой, не заставляя считать индексы вручную.
class EntranceList extends StatelessWidget {
  const EntranceList({super.key, required this.children, this.from = 0});

  final List<Widget> children;

  /// С какого номера начинать задержку.
  final int from;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed)
        Entrance(index: from + index, child: child),
    ],
  );
}

import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Делает любой элемент «нажимаемым»: под пальцем он слегка проседает.
///
/// Это главный источник ощущения отзывчивости — дешевле и заметнее любой
/// другой анимации.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Насколько сжимать под нажатием.
  final double scale;

  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _set(bool value) {
    if (!_active || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => _set(true),
    onTapUp: (_) => _set(false),
    onTapCancel: () => _set(false),
    onTap: _active ? widget.onTap : null,
    onLongPress: _active ? widget.onLongPress : null,
    child: AnimatedScale(
      scale: _down ? widget.scale : 1,
      duration: AppMotion.instant,
      curve: AppMotion.enter,
      child: widget.child,
    ),
  );
}

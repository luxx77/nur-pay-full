import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Рамка видоискателя: четыре уголка и бегущая внутри линия сканирования.
///
/// Луч идёт только сверху вниз, появляясь у верхнего края и растворяясь
/// у нижнего, — так нет рывка на развороте. Никакой тёмной подложки —
/// только уголки и линия поверх картинки с камеры.
class ScannerFrame extends StatefulWidget {
  const ScannerFrame({
    super.key,
    required this.accent,
    this.size,
    this.scanning = true,
  });

  final Color accent;
  final double? size;

  /// Луч идёт, пока ищем код; после распознавания замирает.
  final bool scanning;

  @override
  State<ScannerFrame> createState() => _ScannerFrameState();
}

class _ScannerFrameState extends State<ScannerFrame>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Луч замедляется к краям и идёт ровно в середине кадра.
  late final _sweep = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.scanning) _controller.repeat();
  }

  @override
  void didUpdateWidget(ScannerFrame old) {
    super.didUpdateWidget(old);
    if (widget.scanning == old.scanning) return;
    if (widget.scanning) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = widget.size ?? 260.r;

    return SizedBox(
      width: side,
      height: side,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (_, _) => CustomPaint(
          painter: _ScannerFramePainter(
            accent: widget.accent,
            position: _sweep.value,
            scanning: widget.scanning,
          ),
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter({
    required this.accent,
    required this.position,
    required this.scanning,
  });

  final Color accent;

  /// Где сейчас луч: 0 — у верхнего края, 1 — у нижнего.
  final double position;
  final bool scanning;

  static const _arm = 28.0;
  static const _radius = 16.0;
  static const _inset = 4.0;
  static const _trail = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCorners(canvas, size);
    if (scanning) _paintBeam(canvas, size);
  }

  void _paintCorners(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    const r = _radius;
    const arm = _arm;

    canvas
      ..drawPath(
        Path()
          ..moveTo(0, arm)
          ..lineTo(0, r)
          ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
          ..lineTo(arm, 0),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(w - arm, 0)
          ..lineTo(w - r, 0)
          ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
          ..lineTo(w, arm),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(w, h - arm)
          ..lineTo(w, h - r)
          ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
          ..lineTo(w - arm, h),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(arm, h)
          ..lineTo(r, h)
          ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
          ..lineTo(0, h - arm),
        paint,
      );
  }

  void _paintBeam(Canvas canvas, Size size) {
    // Луч гаснет у краёв, поэтому возврат в начало не виден.
    final fade = math.min(
      _ramp(position, 0, 0.14),
      _ramp(1 - position, 0, 0.2),
    );
    if (fade <= 0) return;

    canvas
      ..save()
      ..clipRect(Offset.zero & size);

    final y = _inset + (size.height - _inset * 2) * position;
    final left = _inset;
    final right = size.width - _inset;

    // Шлейф всегда позади луча — он и задаёт направление движения.
    final band = Rect.fromLTRB(left, y - _trail, right, y);
    canvas
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0),
              accent.withValues(alpha: 0.26 * fade),
            ],
          ).createShader(band),
      )
      ..drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = accent.withValues(alpha: fade)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
      )
      ..restore();
  }

  /// Плавная ступенька от 0 до 1 на отрезке [from, to].
  double _ramp(double value, double from, double to) {
    if (value <= from) return 0;
    if (value >= to) return 1;
    final t = (value - from) / (to - from);
    return t * t * (3 - 2 * t);
  }

  @override
  bool shouldRepaint(_ScannerFramePainter old) =>
      old.accent != accent ||
      old.position != position ||
      old.scanning != scanning;
}

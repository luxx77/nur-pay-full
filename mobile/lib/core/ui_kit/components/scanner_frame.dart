import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Рамка видоискателя: четыре уголка и бегущая линия сканирования.
///
/// Луч идёт только сверху вниз, появляясь у верхнего края и растворяясь
/// у нижнего, — так нет рывка на развороте. Цвет уголков задаёт
/// направление денег: `secondary` — приём, нейтральный — возврат.
class ScannerFrame extends StatefulWidget {
  const ScannerFrame({
    super.key,
    required this.accent,
    this.size,
    this.scanning = true,
    this.transparent = false,
  });

  final Color accent;
  final double? size;

  /// Поверх живой картинки подложка не нужна.
  final bool transparent;

  /// Луч идёт, пока ищем код; после распознавания замирает.
  final bool scanning;

  @override
  State<ScannerFrame> createState() => _ScannerFrameState();
}

class _ScannerFrameState extends State<ScannerFrame>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Луч замедляется к краям и идёт ровно в середине кадра.
  late final _sweep = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  /// Появление и растворение уголков при захвате кода.
  late final _capture = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
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
      _capture.reverse();
    } else {
      _controller.stop();
      _capture.forward();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _capture.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = widget.size ?? 260.r;

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: widget.transparent ? null : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(_ScannerFramePainter.radius.r),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_sweep, _capture]),
        builder: (_, _) => CustomPaint(
          painter: _ScannerFramePainter(
            accent: widget.accent,
            position: _sweep.value,
            scanning: widget.scanning,
            capture: _capture.value,
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
    required this.capture,
  });

  final Color accent;

  /// Где сейчас луч: 0 — у верхнего края, 1 — у нижнего.
  final double position;
  final bool scanning;

  /// 0 — поиск, 1 — код распознан: уголки подтягиваются внутрь.
  final double capture;

  static const _arm = 52.0;
  static const radius = 28.0;
  static const _radius = radius;
  static const _inset = 14.0;
  static const _trail = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCorners(canvas, size);
    if (scanning) _paintBeam(canvas, size);
  }

  void _paintCorners(Canvas canvas, Size size) {
    // При захвате уголки сжимаются к центру и слегка утолщаются —
    // движение читается как «поймал».
    final shrink = 10.0 * capture;
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 4 + capture
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width - shrink * 2;
    final h = size.height - shrink * 2;
    const r = _radius;
    const arm = _arm;

    canvas
      ..save()
      ..translate(shrink, shrink)
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
      )
      ..restore();
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
      ..clipRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    final y = _inset + (size.height - _inset * 2) * position;
    const left = _inset;
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
      old.scanning != scanning ||
      old.capture != capture;
}

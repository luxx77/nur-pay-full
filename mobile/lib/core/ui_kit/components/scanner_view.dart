import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scanner_frame.dart';

/// Полноэкранный сканер: картинка с камеры, затемнение с окном и рамка.
///
/// Если камеры нет — например в симуляторе — остаётся тёмный фон, а окно
/// работает как кнопка: нажатие отдаёт [onSimulate]. Так сценарий кассы
/// проходится и без железа.
class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.accent,
    required this.onDetect,
    this.onSimulate,
    this.active = true,
    this.windowSize,
  });

  final Color accent;

  /// Содержимое распознанного кода.
  final ValueChanged<String> onDetect;

  /// Нажатие на окно, когда камера недоступна.
  final VoidCallback? onSimulate;

  /// Пока `false`, распознавание не срабатывает — код уже принят.
  final bool active;

  final double? windowSize;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _cameraFailed = false;
  bool _handled = false;

  @override
  void didUpdateWidget(ScannerView old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _handled = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!widget.active || _handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null) return;
    _handled = true;
    widget.onDetect(raw);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final window = widget.windowSize ?? 262.r;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final rect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 - 24.h),
          width: window,
          height: window,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (!_cameraFailed)
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (_, _) {
                  // Камеры нет — уходим в ручной режим, но не роняем экран.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_cameraFailed) {
                      setState(() => _cameraFailed = true);
                    }
                  });
                  return ColoredBox(color: cs.surface);
                },
              )
            else
              ColoredBox(color: cs.surface),

            // Затемнение с прозрачным окном — взгляд сам идёт в кадр.
            IgnorePointer(
              child: CustomPaint(
                painter: _WindowScrimPainter(
                  window: rect,
                  color: cs.surface.withValues(
                    alpha: _cameraFailed ? 0.4 : 0.72,
                  ),
                  radius: 28.r,
                ),
              ),
            ),

            Positioned.fromRect(
              rect: rect,
              child: GestureDetector(
                onTap: widget.onSimulate,
                child: ScannerFrame(
                  accent: widget.accent,
                  size: window,
                  scanning: widget.active,
                  transparent: !_cameraFailed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WindowScrimPainter extends CustomPainter {
  const _WindowScrimPainter({
    required this.window,
    required this.color,
    required this.radius,
  });

  final Rect window;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(window, Radius.circular(radius)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlay, hole),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_WindowScrimPainter old) =>
      old.window != window || old.color != color || old.radius != radius;
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../foundation/app_radius.dart';
import 'scanner_frame.dart';

/// Полноэкранный сканер: картинка с камеры, рамка с уголками и линией,
/// подсказка над рамкой и кнопки «Галерея» / вспышка под ней.
///
/// Никакого затемнения — камера видна целиком, рамка лишь очерчивает
/// зону кадра.
///
/// Если камеры нет — например в симуляторе — остаётся нейтральный фон, а
/// рамка работает как кнопка: нажатие отдаёт [onSimulate]. Так сценарий
/// кассы проходится и без железа.
class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.accent,
    required this.onDetect,
    required this.hint,
    this.onSimulate,
    this.active = true,
    this.windowSize,
  });

  final Color accent;

  /// Содержимое распознанного кода.
  final ValueChanged<String> onDetect;

  /// Подсказка над рамкой.
  final String hint;

  /// Нажатие на рамку, когда камера недоступна.
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
  bool _pickingFromGallery = false;

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
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    _handle(raw);
  }

  void _handle(String? raw) {
    if (!widget.active || _handled || raw == null) return;
    _handled = true;
    widget.onDetect(raw);
  }

  Future<void> _pickFromGallery() async {
    if (!widget.active || _pickingFromGallery) return;
    setState(() => _pickingFromGallery = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final capture = await _controller.analyzeImage(image.path);
      final raw = capture?.barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .firstOrNull;
      _handle(raw);
    } finally {
      if (mounted) setState(() => _pickingFromGallery = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final window = widget.windowSize ?? 260.r;

    return GestureDetector(
      onTap: _cameraFailed ? widget.onSimulate : null,
      child: Stack(
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

          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.hint,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: widget.active ? cs.onSurface : widget.accent,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  IgnorePointer(
                    child: ScannerFrame(
                      accent: widget.accent,
                      size: window,
                      scanning: widget.active,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GalleryPillButton(
                        loading: _pickingFromGallery,
                        onTap: widget.active ? _pickFromGallery : null,
                      ),
                      SizedBox(width: 12.w),
                      _FlashButton(
                        controller: _controller,
                        enabled: !_cameraFailed && widget.active,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Пилюля «Galereýadan saýla» — выбор фото с кодом вместо камеры.
class _GalleryPillButton extends StatelessWidget {
  const _GalleryPillButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: AppRadius.pillAll,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Galereýadan saýla',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

/// Круглая кнопка фонарика — включает вспышку камеры для тёмных мест.
class _FlashButton extends StatelessWidget {
  const _FlashButton({required this.controller, required this.enabled});

  final MobileScannerController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, state, _) {
      final on = state.torchState == TorchState.on;

      return Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? controller.toggleTorch : null,
          child: SizedBox(
            width: 44.h,
            height: 44.h,
            child: Icon(
              on ? Icons.flash_on : Icons.flash_off,
              size: 20.r,
              color: Colors.white,
            ),
          ),
        ),
      );
    },
  );
}

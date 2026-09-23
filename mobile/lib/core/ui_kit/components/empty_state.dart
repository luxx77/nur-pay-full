import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';

/// Пустое состояние: штрихованный значок, заголовок, пояснение и действия.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
    this.icon,
  });

  final String title;
  final String message;
  final List<Widget> actions;

  /// Своя иконка вместо штриховки.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? const _HatchedGlyph(),
            SizedBox(height: 14.h),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            SizedBox(height: 10.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                height: 1.55,
                color: cs.onSurfaceVariant,
              ),
            ),
            if (actions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              ...actions.map(
                (a) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: a,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HatchedGlyph extends StatelessWidget {
  const _HatchedGlyph();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(borderRadius: AppRadius.xlAll),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _HatchPainter(
          light: cs.surfaceContainerLowest,
          dark: cs.outlineVariant,
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = light);
    final paint = Paint()
      ..color = dark
      ..strokeWidth = 7;
    for (var i = -size.height; i < size.width; i += 14) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) =>
      old.light != light || old.dark != dark;
}

/// Крупный круглый значок результата: галочка успеха, «!» ошибки, «⟳» ожидания.
enum ResultGlyphTone { success, successSoft, pending, error }

class ResultGlyph extends StatelessWidget {
  const ResultGlyph({super.key, required this.tone, this.size});

  final ResultGlyphTone tone;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = size ?? 88.r;

    final (Color bg, Color fg, IconData icon) = switch (tone) {
      ResultGlyphTone.success => (
        cs.secondary,
        cs.onSecondary,
        Icons.check_rounded,
      ),
      ResultGlyphTone.successSoft => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        Icons.check_rounded,
      ),
      ResultGlyphTone.pending => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        Icons.refresh_rounded,
      ),
      ResultGlyphTone.error => (
        cs.errorContainer,
        cs.onErrorContainer,
        Icons.priority_high_rounded,
      ),
    };

    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: side * 0.52, color: fg),
    );
  }
}

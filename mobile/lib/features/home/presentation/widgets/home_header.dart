import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ui_kit/ui_kit.dart';

/// Шапка главного экрана: знак, состояние сети и кнопка своего QR.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.title,
    required this.online,
    this.onQrTap,
    this.onStatusTap,
    this.trailing,
  });

  final String title;
  final bool online;
  final VoidCallback? onQrTap;

  /// Тап по бейджу переключает сеть — так проверяются офлайн-состояния.
  final VoidCallback? onStatusTap;

  /// Заменяет пару «бейдж + QR» целиком (шапка мерчанта).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
    child: Row(
      children: [
        Expanded(child: BrandLockup(title: title)),
        SizedBox(width: 10.w),
        if (trailing != null)
          trailing!
        else ...[
          GestureDetector(
            onTap: onStatusTap,
            child: AppStatusBadge(
              label: online ? 'Onlaýn' : 'Oflaýn',
              tone: online ? AppStatusTone.success : AppStatusTone.neutral,
            ),
          ),
          if (onQrTap != null) ...[
            SizedBox(width: 10.w),
            AppIconButton(icon: Icons.qr_code_2_rounded, onPressed: onQrTap),
          ],
        ],
      ],
    ),
  );
}

/// Док внизу главного экрана: два действия, требующих сети.
class HomeActionDock extends StatelessWidget {
  const HomeActionDock({
    super.key,
    required this.onTransfer,
    required this.onTopUp,
    this.enabled = true,
    this.note,
  });

  final VoidCallback? onTransfer;
  final VoidCallback? onTopUp;
  final bool enabled;

  /// Пояснение под кнопками, когда сети нет.
  final String? note;

  /// Высота дока — по ней плавающая кнопка отступает от него так,
  /// чтобы её тень не обрезалась краем панели.
  static double heightOf({required bool withNote}) =>
      12.h + 56.h + 14.h + (withNote ? 8.h + 34.h : 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton.tonal(
                  label: 'Pul geçir',
                  size: AppButtonSize.large,
                  onPressed: enabled ? onTransfer : null,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppButton.neutral(
                  label: 'Hasaby doldur',
                  size: AppButtonSize.large,
                  onPressed: enabled ? onTopUp : null,
                ),
              ),
            ],
          ),
          if (note != null) ...[
            SizedBox(height: 8.h),
            Text(
              note!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: cs.outline),
            ),
          ],
        ],
      ),
    );
  }
}

/// Список последних операций в белой карточке с разделителями.
class OperationsCard extends StatelessWidget {
  const OperationsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(color: cs.outlineVariant, height: 1));
      }
    }
    return AppCard.list(child: Column(children: rows));
  }
}

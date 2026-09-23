import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../../theme/app_typography.dart';

/// Строка «ключ — значение» в чеке и подтверждении.
class DetailRow {
  const DetailRow(
    this.label,
    this.value, {
    this.mono = false,
    this.emphasized = false,
    this.valueWidget,
  });

  final String label;
  final String value;

  /// Моноширинно — для ID операции.
  final bool mono;

  /// Крупнее — для итоговой суммы.
  final bool emphasized;

  /// Произвольный виджет вместо текста (например, бейдж статуса).
  final Widget? valueWidget;
}

/// Список деталей операции. В макете два вида: в рамке и на мягкой подложке.
class DetailList extends StatelessWidget {
  const DetailList({super.key, required this.rows, this.filled = false});

  /// На мягкой подложке `surfaceContainer`, без рамки.
  const DetailList.filled({super.key, required this.rows}) : filled = true;

  final List<DetailRow> rows;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: filled ? 0 : 14.w,
            vertical: 14.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  style: text.bodyMedium?.copyWith(
                    fontSize: filled ? 16.sp : 15.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              row.valueWidget ??
                  Text(
                    row.value,
                    style: row.mono
                        ? AppTypography.monospace(
                            text.bodyMedium!.copyWith(
                              fontSize: filled ? 16.sp : 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          )
                        : AppTypography.tabular(
                            (row.emphasized
                                    ? text.titleSmall!
                                    : text.bodyMedium!)
                                .copyWith(
                                  fontSize: filled ? 17.sp : 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                          ),
                  ),
            ],
          ),
        ),
      );
      if (i != rows.length - 1) {
        children.add(Divider(color: cs.outlineVariant, height: 1));
      }
    }

    final content = Column(children: children);

    if (filled) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: AppRadius.lgAll,
        ),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

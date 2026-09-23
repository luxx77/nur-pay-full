import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/entities/operation.dart';

/// Шторка «Çeki paýlaş»: текст чека и копирование в буфер.
///
/// Системного share здесь пока нет — вместо него честное копирование,
/// чтобы действие что-то делало уже сейчас.
class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key, required this.operation});

  final Operation operation;

  static Future<void> show(
    BuildContext context, {
    required Operation operation,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.42),
    builder: (_) => ShareSheet(operation: operation),
  );

  String get _receipt => [
    'Nur Pay · çek',
    '${operation.isIncoming ? 'Alyndy' : 'Geçirildi'}: '
        '${operation.amount.withCurrency}',
    operation.counterparty.title,
    TmDate.receipt(operation.createdAt),
    '#${operation.id}',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AppSheet(
      title: 'Çeki paýlaş',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              _receipt,
              style: text.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
          Gap(16.h),
          AppButton.filled(
            label: 'Göçür',
            icon: Icons.copy_rounded,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _receipt));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Çek göçürildi')));
            },
          ),
          Gap(10.h),
          AppButton.outlined(
            label: 'Ýap',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/ui_kit/ui_kit.dart';

/// 5.1 · Usuly saýlaň — способ пополнения.
///
/// Код активации работает офлайн и встаёт в очередь. Пополнение у агента
/// (постоянный QR) временно убрано с экрана — способ единственный, выбор
/// между ними не нужен.
class TopUpMethodPage extends StatelessWidget {
  const TopUpMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Hasaby doldur'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Usuly saýlaň',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Gap(16.h),
                  AppSelectableCard(
                    title: 'Işjeňleşdirme kody',
                    description:
                        'Satyn alan kartaňyzdaky 12 belgili kody giriziň. '
                        'Kod internet gelende işlener.',
                    leading: const Text('##'),
                    selected: true,
                    onTap: () => context.push(AppRoutes.topUpCode),
                  ),
                  const Spacer(),
                  AppButton.filled(
                    label: 'Dowam et',
                    onPressed: () => context.push(AppRoutes.topUpCode),
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

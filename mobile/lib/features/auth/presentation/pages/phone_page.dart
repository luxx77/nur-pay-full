import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/ui_kit/ui_kit.dart';

/// 1.1 · Telefon belgisi — ввод номера телефона.
class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  static const _requiredDigits = 8;

  final _controller = TextEditingController();

  int get _digits => _controller.text.replaceAll(RegExp(r'\D'), '').length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ready = _digits == _requiredDigits;

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: 32.h, bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(size: 44),
            Gap(22.h),
            Text('Telefon belgiňiz', style: text.headlineMedium),
            Gap(8.h),
            Text(
              'Size SMS arkaly kod ugradarys',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Gap(22.h),
            PhoneField(
              controller: _controller,
              helper: '8 sany · operator kody bilen',
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            Text(
              'Dowam etmek bilen hyzmat şertlerini kabul edýärsiňiz',
              style: text.bodySmall?.copyWith(color: cs.outline),
            ),
            Gap(22.h),
            AppButton.filled(
              label: 'Dowam et',
              onPressed: ready
                  ? () => context.push(
                      Uri(
                        path: AppRoutes.otp,
                        queryParameters: {'phone': _controller.text},
                      ).toString(),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

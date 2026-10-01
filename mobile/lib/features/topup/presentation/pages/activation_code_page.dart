import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/input/amount_editor.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../bloc/activation_cubit.dart';

/// 5.2 · Işjeňleşdirme kody — 12 цифр с карты пополнения.
///
/// Номинал карты известен только после погашения: спрашивать его заранее
/// нельзя, иначе коды можно было бы перебирать, не тратя.
class ActivationCodePage extends StatefulWidget {
  const ActivationCodePage({super.key});

  @override
  State<ActivationCodePage> createState() => _ActivationCodePageState();
}

class _ActivationCodePageState extends State<ActivationCodePage> {
  static const _length = 12;

  final _editor = DigitsEditor(length: _length);

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onChanged);
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _submit() async {
    final activation = context.read<ActivationCubit>();
    final activated = await activation.activate(_editor.digits);
    if (!mounted) return;

    if (!activated) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              activation.state.error?.userMessage ?? 'Kod işlemedi',
            ),
          ),
        );
      return;
    }

    await context.read<WalletCubit>().refresh();
    if (mounted) context.go(AppRoutes.topUpSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final busy = context.watch<ActivationCubit>().state.busy;

    // Не AppTypography.monospace: у нуля в IBM Plex Mono точка внутри
    // (так отличают «0» от «O»), а тут её путают с точкой-заглушкой.
    // В Sans цифры и так одинаковой ширины — выравнивание не теряется.
    final codeStyle = AppTypography.tabular(
      text.headlineSmall!.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
      ),
    ).copyWith(letterSpacing: 0.08 * 24.sp);

    final missing = _length - _editor.filled;
    final digits = _editor.digits;

    // Точки-заглушки группируются по четыре вместе с цифрами — иначе после
    // ввода первой цифры группы остаток точек съезжает в один сплошной
    // кусок и перестаёт совпадать с делением «XXXX XXXX XXXX».
    List<InlineSpan> group(int start) => [
      for (var i = start; i < start + 4 && i < _length; i++)
        i < digits.length
            ? TextSpan(text: digits[i])
            : TextSpan(text: '·', style: TextStyle(color: cs.outline)),
    ];

    return AppScaffold(
      padded: false,
      body: Column(
        children: [
          const AppTopBar(title: 'Işjeňleşdirme kody'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kartanyň arka ýüzündäki gorag gatlagyny süpüriň '
                    'we 12 belgini giriziň',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Gap(16.h),
                  DisplayField(
                    focused: true,
                    child: Text.rich(
                      TextSpan(
                        style: codeStyle,
                        children: [
                          for (var i = 0; i < _length; i += 4) ...[
                            if (i > 0) const TextSpan(text: ' '),
                            ...group(i),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Gap(16.h),
                  InfoBanner(
                    title: missing > 0
                        ? '$missing belgi galdy'
                        : 'Kartanyň bahasy koddan kesgitlener',
                    tone: InfoBannerTone.brand,
                    showDot: false,
                  ),
                  const Spacer(),
                  NumericKeypad(
                    onKey: _editor.push,
                    onBackspace: _editor.backspace,
                    onBackspaceLongPress: _editor.clear,
                  ),
                  Gap(14.h),
                  AppButton.filled(
                    label: 'Hasaby doldur',
                    loading: busy,
                    onPressed: _editor.isComplete && !busy ? _submit : null,
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

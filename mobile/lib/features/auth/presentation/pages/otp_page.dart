import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/input/amount_editor.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/tm_date.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../bloc/session_cubit.dart';

/// 1.2 · SMS kody — подтверждение номера.
///
/// Кода на сервере нет: в прототипе вход без OTP. Экран оставлен как шаг
/// сценария, а настоящий вход происходит по кнопке «Tassykla».
class OtpPage extends StatefulWidget {
  const OtpPage({super.key, this.phone = ''});

  final String phone;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _resendSeconds = 45;

  final _editor = DigitsEditor(length: 4);

  Timer? _ticker;
  int _left = _resendSeconds;
  bool _busy = false;
  String? _error;

  /// Номер в том виде, в каком его ждёт сервер: +99361188798, без пробелов.
  String get _phone => '+993${widget.phone.replaceAll(RegExp(r'\D'), '')}';

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onInput);
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _editor
      ..removeListener(_onInput)
      ..dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    setState(() => _left = _resendSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_left <= 1) timer.cancel();
      setState(() => _left = _left > 0 ? _left - 1 : 0);
    });
  }

  void _onInput() => setState(() => _error = null);

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Router сам уведёт дальше, как только появится сессия.
      await context.read<SessionCubit>().login(_phone);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.userMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final canResend = _left == 0;

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32.h, bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kody giriziň', style: text.headlineMedium),
            Gap(8.h),
            Text(
              '$_phone belgä ugradyldy',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Gap(22.h),
            Shake(
              trigger: _error == null ? 0 : 1,
              child: OtpField(value: _editor.digits, error: _error != null),
            ),
            Gap(22.h),
            GestureDetector(
              onTap: canResend ? _startTimer : null,
              child: Text(
                canResend
                    ? 'Kody gaýtadan ugrat'
                    : 'Kody gaýtadan ugrat — 0:${TmDate.two(_left)}',
                style: text.bodyMedium?.copyWith(
                  color: canResend ? cs.primary : cs.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (_error != null) ...[
              Gap(10.h),
              Text(_error!, style: text.bodyMedium?.copyWith(color: cs.error)),
            ],
            const Spacer(),
            NumericKeypad(
              keyHeight: 62.h,
              onKey: _editor.push,
              onBackspace: _editor.backspace,
              onBackspaceLongPress: _editor.clear,
            ),
            Gap(14.h),
            AppButton.filled(
              label: 'Tassykla',
              loading: _busy,
              onPressed: _editor.isComplete ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

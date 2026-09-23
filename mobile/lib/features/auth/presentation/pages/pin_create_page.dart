import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/input/amount_editor.dart';
import '../../../../core/session/pin_storage.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../bloc/session_cubit.dart';

/// 1.3 · PIN dörediň — создание PIN при первом входе.
///
/// PIN живёт только на устройстве: у бэкенда его нет, это локальный замок
/// перед подтверждением операций.
class PinCreatePage extends StatefulWidget {
  const PinCreatePage({super.key});

  @override
  State<PinCreatePage> createState() => _PinCreatePageState();
}

class _PinCreatePageState extends State<PinCreatePage> {
  final _editor = DigitsEditor(length: PinStorage.length);

  String? _first;
  bool _error = false;
  int _mismatches = 0;
  Timer? _timer;

  bool get _repeating => _first != null;

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onInput);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _editor
      ..removeListener(_onInput)
      ..dispose();
    super.dispose();
  }

  void _onInput() {
    setState(() => _error = false);
    if (!_editor.isComplete) return;

    final entered = _editor.digits;

    if (!_repeating) {
      _timer = Timer(const Duration(milliseconds: 160), () {
        if (!mounted) return;
        setState(() => _first = entered);
        _editor.clear();
      });
      return;
    }

    if (entered != _first) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() {
        _error = true;
        _mismatches++;
      });
      _timer = Timer(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        setState(() => _first = null);
        _editor.clear();
      });
      return;
    }

    unawaited(HapticFeedback.lightImpact());
    // Router уведёт на главный, как только замок будет поставлен.
    unawaited(context.read<SessionCubit>().setPin(entered));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final subtitle = _error
        ? 'Kodlar gabat gelmedi. Täzeden başlaň.'
        : _repeating
        ? 'Tassyklamak üçin gaýtalaň'
        : 'Her tölegde şu 4 sany soralar';

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 32.h, bottom: 20.h),
        child: Column(
          children: [
            Text(
              _repeating ? 'PIN-i gaýtalaň' : 'PIN dörediň',
              style: text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Gap(14.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: _error ? cs.error : cs.onSurfaceVariant,
              ),
            ),
            Gap(24.h),
            Shake(
              trigger: _mismatches,
              child: PinDots(
                filled: _editor.filled,
                length: _editor.length,
                error: _error,
              ),
            ),
            const Spacer(),
            NumericKeypad(
              keyHeight: 72.h,
              onKey: _editor.push,
              onBackspace: _editor.backspace,
              onBackspaceLongPress: _editor.clear,
            ),
          ],
        ),
      ),
    );
  }
}

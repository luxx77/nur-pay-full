import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/input/amount_editor.dart';
import '../../../../core/session/pin_storage.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';

/// Шторка подтверждения PIN.
///
/// Поднимается везде, где нужно подтверждение. Проверка локальная: PIN
/// хранится на устройстве, сервер о нём не знает.
class PinSheet extends StatefulWidget {
  const PinSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.onCompleted,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onCompleted;

  /// Показать шторку и вызвать [onCompleted] после верного PIN.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    VoidCallback? onCompleted,
  }) {
    final session = context.read<SessionCubit>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.42),
      builder: (sheetContext) => BlocProvider.value(
        value: session,
        child: PinSheet(
          title: title,
          subtitle: subtitle,
          onCompleted: () {
            Navigator.of(sheetContext).pop();
            onCompleted?.call();
          },
        ),
      ),
    );
  }

  @override
  State<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<PinSheet> {
  final _editor = DigitsEditor(length: PinStorage.length);

  bool _error = false;
  int _attempts = 0;
  Timer? _timer;

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

  Future<void> _onInput() async {
    setState(() {});
    if (!_editor.isComplete) return;

    final correct = await context.read<SessionCubit>().verifyPin(
      _editor.digits,
    );
    if (!mounted) return;

    if (correct) {
      unawaited(HapticFeedback.lightImpact());
      _timer = Timer(const Duration(milliseconds: 180), () {
        if (mounted) widget.onCompleted?.call();
      });
      return;
    }

    unawaited(HapticFeedback.heavyImpact());
    setState(() {
      _error = true;
      _attempts++;
    });
    _timer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() => _error = false);
      _editor.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AppSheet(
      title: widget.title,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _error ? 'PIN nädogry' : widget.subtitle,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              fontSize: 14.5.sp,
              color: _error ? cs.error : cs.onSurfaceVariant,
            ),
          ),
          Gap(12.h),
          Shake(
            trigger: _attempts,
            child: PinDots(
              filled: _editor.filled,
              length: _editor.length,
              error: _error,
            ),
          ),
          Gap(12.h),
          NumericKeypad(
            keyHeight: 62.h,
            onKey: _editor.push,
            onBackspace: _editor.backspace,
            onBackspaceLongPress: _editor.clear,
          ),
        ],
      ),
    );
  }
}

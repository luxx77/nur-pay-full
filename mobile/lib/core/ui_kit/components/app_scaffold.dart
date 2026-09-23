import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Каркас экрана Nur Pay.
///
/// Фон берётся из `surfaceContainerLow` — он несёт оттенок роли
/// (голубоватый у клиента, зеленоватый у мерчанта).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.padded = true,
    this.safeBottom = true,
    this.resizeToAvoidBottomInset = false,
    this.extendBody = false,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  /// Горизонтальные поля 20 pt вокруг [body].
  final bool padded;
  final bool safeBottom;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? cs.surfaceContainerLow,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: SafeArea(
        bottom: safeBottom,
        child: padded
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: body,
              )
            : body,
      ),
    );
  }
}

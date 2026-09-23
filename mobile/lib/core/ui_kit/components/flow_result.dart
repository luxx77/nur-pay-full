import 'package:flutter/material.dart';

/// Обёртка экрана результата.
///
/// Экран результата закрывает сценарий, поэтому системное «назад» должно
/// вести туда же, куда главная кнопка, а не выбрасывать из приложения.
class FlowResult extends StatelessWidget {
  const FlowResult({super.key, required this.onExit, required this.child});

  final VoidCallback onExit;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) onExit();
    },
    child: child,
  );
}

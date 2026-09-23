import 'package:flutter/material.dart';

import '../../core/ui_kit/ui_kit.dart';

/// Переключатель вкладок с растворением.
///
/// Все ветки остаются живыми — вкладка не теряет прокрутку и состояние, —
/// но переход между ними больше не мгновенная подмена кадра.
class BranchSwitcher extends StatelessWidget {
  const BranchSwitcher({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (final (index, child) in children.indexed)
        _Branch(active: index == currentIndex, child: child),
    ],
  );
}

class _Branch extends StatelessWidget {
  const _Branch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: active ? 1 : 0,
    duration: AppMotion.quick,
    curve: AppMotion.enter,
    child: AnimatedScale(
      scale: active ? 1 : 0.98,
      duration: AppMotion.quick,
      curve: AppMotion.enter,
      child: IgnorePointer(
        ignoring: !active,
        // Неактивная ветка не рисуется, но и не выбрасывается из дерева.
        child: TickerMode(enabled: active, child: child),
      ),
    ),
  );
}

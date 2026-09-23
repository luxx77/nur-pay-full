import 'package:flutter/material.dart';

import '../../money.dart';
import 'app_motion.dart';

/// Сумма, которая перетекает к новому значению.
///
/// Баланс после операции не перескакивает — он доезжает, и глаз успевает
/// заметить, что именно изменилось.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    super.key,
    required this.value,
    required this.builder,
    this.duration = AppMotion.page,
  });

  final Money value;
  final Duration duration;

  /// Как нарисовать промежуточное значение.
  final Widget Function(BuildContext context, Money value) builder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<int>(
    tween: IntTween(begin: value.minor, end: value.minor),
    duration: duration,
    curve: AppMotion.standard,
    builder: (context, minor, _) => builder(context, Money(minor)),
  );
}

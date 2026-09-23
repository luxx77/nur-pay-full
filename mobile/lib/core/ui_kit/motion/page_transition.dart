import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Переход между экранами стека.
///
/// Новый экран приезжает справа и проявляется, старый слегка уходит влево
/// и притухает — получается ощущение глубины без «шторки» на весь экран.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );
    final leave = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.standard,
    );

    return AnimatedBuilder(
      animation: leave,
      builder: (context, child) => Transform.translate(
        offset: Offset(-40 * leave.value, 0),
        child: Opacity(opacity: 1 - 0.18 * leave.value, child: child),
      ),
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.22, 0),
          end: Offset.zero,
        ).animate(enter),
        child: FadeTransition(opacity: enter, child: child),
      ),
    );
  }
}

/// Появление шторки или диалога поверх экрана.
class AppOverlayTransition extends StatelessWidget {
  const AppOverlayTransition({
    super.key,
    required this.animation,
    required this.child,
    this.slide = 0.06,
    this.scaleFrom = 0.96,
  });

  final Animation<double> animation;
  final Widget child;

  /// Насколько подъезжает снизу, в долях высоты.
  final double slide;

  /// С какого масштаба появляется.
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, slide),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween(begin: scaleFrom, end: 1.0).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

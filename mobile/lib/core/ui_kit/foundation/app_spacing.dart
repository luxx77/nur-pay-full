import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Шаг сетки — 4 pt. Значения уже отмасштабированы ScreenUtil.
abstract final class AppSpacing {
  static double get xxs => 4.w;
  static double get xs => 8.w;
  static double get sm => 10.w;
  static double get md => 12.w;
  static double get lg => 14.w;
  static double get xl => 18.w;
  static double get xxl => 22.w;
  static double get xxxl => 30.w;

  /// Горизонтальные поля экрана.
  static double get screenH => 20.w;

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 20.w);
}

/// Вертикальный отступ-распорка.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}

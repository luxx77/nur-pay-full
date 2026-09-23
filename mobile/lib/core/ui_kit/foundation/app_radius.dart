import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Радиусы скруглений.
///
/// Шкала крупная и мягкая: у интерфейса, где речь о деньгах, острые углы
/// читаются как тревога.
abstract final class AppRadius {
  static double get xs => 8.r;
  static double get sm => 12.r;
  static double get md => 16.r;
  static double get lg => 18.r;
  static double get xl => 22.r;
  static double get xxl => 26.r;
  static double get sheet => 30.r;
  static double get pill => 999.r;

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get xxlAll => BorderRadius.circular(xxl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);

  static BorderRadius get sheetTop =>
      BorderRadius.vertical(top: Radius.circular(sheet));
}

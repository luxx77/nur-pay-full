import 'package:flutter/material.dart';

/// Единая шкала движения.
///
/// Длительности подобраны так, чтобы интерфейс отвечал мгновенно, а не
/// «показывал анимацию»: отклик на нажатие — кадры, переход экрана —
/// треть секунды.
abstract final class AppMotion {
  /// Отклик на касание.
  static const instant = Duration(milliseconds: 120);

  /// Переключение состояния внутри экрана.
  static const quick = Duration(milliseconds: 220);

  /// Появление блока, смена содержимого.
  static const medium = Duration(milliseconds: 340);

  /// Переход между экранами и шторки.
  static const page = Duration(milliseconds: 380);

  /// Основная кривая: быстрый старт, мягкая остановка.
  static const enter = Curves.easeOutCubic;

  /// Уход элемента.
  static const exit = Curves.easeInCubic;

  /// Для того, что едет туда и обратно.
  static const standard = Curves.easeInOutCubic;

  /// Лёгкий «перелёт» — для появления значков и кнопок.
  static const overshoot = Curves.easeOutBack;
}

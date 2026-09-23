import 'package:flutter/material.dart';

import '../app_role.dart';
import 'app_theme.dart';

/// Локально переключает цветовую схему поддерева.
///
/// Экраны мерчанта оборачиваются в `RoleTheme(role: AppRole.merchant, …)`,
/// сканер — дополнительно в `brightness: Brightness.dark`. Виджеты внутри
/// по-прежнему читают только `Theme.of(context).colorScheme`.
class RoleTheme extends StatelessWidget {
  const RoleTheme({
    super.key,
    required this.role,
    required this.child,
    this.brightness = Brightness.light,
  });

  /// Тёмная схема текущей роли — для полноэкранного сканера.
  const RoleTheme.dark({super.key, required this.role, required this.child})
    : brightness = Brightness.dark;

  final AppRole role;
  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: AppTheme.of(role, brightness), child: child);
}

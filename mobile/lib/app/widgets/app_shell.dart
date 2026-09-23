import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/ui_kit/ui_kit.dart';

/// Оболочка вкладок: Esasy · Taryh · Profil.
///
/// Нижняя панель живёт здесь, поэтому у каждой вкладки свой стек и своё
/// состояние. Роль задаёт цветовую схему всей оболочки.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.role,
  });

  final StatefulNavigationShell navigationShell;
  final AppRole role;

  @override
  Widget build(BuildContext context) => RoleTheme(
    role: role,
    child: Builder(
      builder: (context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          items: AppBottomNav.defaultItems,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            // Повторный тап по активной вкладке возвращает её в начало.
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    ),
  );
}

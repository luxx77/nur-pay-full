import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../foundation/app_radius.dart';
import '../motion/app_motion.dart';

/// Пункт нижней навигации.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Нижняя навигация: Esasy · Taryh · Profil.
///
/// Под активной иконкой едет брендовая «таблетка» — она и подсказывает,
/// куда переключились, без резкой смены цвета всей панели.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
  });

  /// Стандартный набор вкладок приложения.
  static const defaultItems = <AppNavItem>[
    AppNavItem(
      label: 'Esasy',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    AppNavItem(
      label: 'Taryh',
      icon: CupertinoIcons.time,
      activeIcon: CupertinoIcons.time_solid,
    ),
    AppNavItem(
      label: 'Profil',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
  ];

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: _NavButton(
                    item: item,
                    active: index == currentIndex,
                    onTap: onTap == null ? null : () => onTap!(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, this.onTap});

  final AppNavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppMotion.quick,
            curve: AppMotion.enter,
            height: 32.h,
            width: active ? 60.w : 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? cs.primaryContainer : Colors.transparent,
              borderRadius: AppRadius.pillAll,
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.quick,
              switchInCurve: AppMotion.enter,
              child: Icon(
                active ? item.activeIcon : item.icon,
                key: ValueKey(active),
                size: 22.r,
                color: active ? cs.onPrimaryContainer : cs.outline,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedDefaultTextStyle(
            duration: AppMotion.quick,
            curve: AppMotion.enter,
            style:
                text.labelSmall?.copyWith(
                  fontSize: 11.5.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ) ??
                const TextStyle(),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

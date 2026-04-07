import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/generated/app_localizations.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home/programs')) {
      return AppConstants.programsTabIndex;
    }
    if (location.startsWith('/home/schedule')) {
      return AppConstants.scheduleTabIndex;
    }
    if (location.startsWith('/home/profile')) {
      return AppConstants.profileTabIndex;
    }
    return AppConstants.mainTabIndex;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case AppConstants.mainTabIndex:
        context.go('/home/main');
        break;
      case AppConstants.programsTabIndex:
        context.go('/home/programs');
        break;
      case AppConstants.scheduleTabIndex:
        context.go('/home/schedule');
        break;
      case AppConstants.profileTabIndex:
        context.go('/home/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final int selectedIndex = _currentIndex(context);

    final tabs = [
      _TabItem(
        iconPath: 'assets/svg/home.svg',
        activeIconPath: 'assets/svg/home.svg',
        label: loc.tabMain,
        index: AppConstants.mainTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/programs.svg',
        activeIconPath: 'assets/svg/programs.svg',
        label: loc.tabPrograms,
        index: AppConstants.programsTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/schedule.svg',
        activeIconPath: 'assets/svg/schedule.svg',
        label: loc.tabSchedule,
        index: AppConstants.scheduleTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/profile.svg',
        activeIconPath: 'assets/svg/profile.svg',
        label: loc.tabProfile,
        index: AppConstants.profileTabIndex,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Основной контент — занимает все пространство
          Positioned(top: 0, left: 0, right: 0, bottom: 0, child: child),

          // Навбар поверх контента — floating
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _FloatingNavBar(
              tabs: tabs,
              selectedIndex: selectedIndex,
              onTabTapped: (index) => _onTabTapped(context, index),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Плавающий навбар ──
class _FloatingNavBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabTapped;

  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.22),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.35),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const totalTabs = 4;
              final sectionWidth = constraints.maxWidth / totalTabs;
              final highlightWidth = min(72.0, max(52.0, sectionWidth - 16));
              final highlightLeft =
                  sectionWidth * selectedIndex +
                  (sectionWidth - highlightWidth) / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: highlightLeft,
                    top: 6,
                    bottom: 6,
                    child: Container(
                      width: highlightWidth,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.54),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: tabs
                        .map(
                          (tab) => _NavBarItem(
                            tab: tab,
                            isSelected: tab.index == selectedIndex,
                            onTap: () => onTabTapped(tab.index),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Одна кнопка навбара ──
class _NavBarItem extends StatelessWidget {
  final _TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Center(
          child: SvgPicture.asset(
            isSelected ? tab.activeIconPath : tab.iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}

// ── Модель вкладки ──
class _TabItem {
  final String iconPath;
  final String activeIconPath;
  final String label;
  final int index;

  const _TabItem({
    required this.iconPath,
    required this.activeIconPath,
    required this.label,
    required this.index,
  });
}

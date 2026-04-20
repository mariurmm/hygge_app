import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = ConstantTween<double>(0.0).animate(_animationController);
  }

  int _currentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home/programs'))
      return AppConstants.programsTabIndex;
    if (location.startsWith('/home/schedule'))
      return AppConstants.scheduleTabIndex;
    if (location.startsWith('/home/profile'))
      return AppConstants.profileTabIndex;
    return AppConstants.mainTabIndex;
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == _lastIndex) return;

    HapticFeedback.mediumImpact();

    _animation =
        Tween<double>(
          begin: _lastIndex.toDouble(),
          end: index.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _animationController.forward(from: 0);
    _lastIndex = index;

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

  Color colorWithOpacity(Color c, double o) =>
      Color.fromRGBO(c.red, c.green, c.blue, o);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final int selectedIndex = _currentIndex(context);

    if (selectedIndex != _lastIndex && !_animationController.isAnimating) {
      _lastIndex = selectedIndex;
      _animation = ConstantTween<double>(
        selectedIndex.toDouble(),
      ).animate(_animationController);
    }

    final tabs = [
      _TabItem(
        iconPath: 'assets/svg/home.svg',
        index: AppConstants.mainTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/programs.svg',
        index: AppConstants.programsTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/schedule.svg',
        index: AppConstants.scheduleTabIndex,
      ),
      _TabItem(
        iconPath: 'assets/svg/profile.svg',
        index: AppConstants.profileTabIndex,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _FloatingNavBar(
                  tabs: tabs,
                  currentIndexValue: _animation.value,
                  targetIndex: selectedIndex,
                  onTabTapped: (index) => _onTabTapped(context, index),
                  colorWithOpacity: colorWithOpacity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final double currentIndexValue;
  final int targetIndex;
  final ValueChanged<int> onTabTapped;
  final Color Function(Color, double) colorWithOpacity;

  const _FloatingNavBar({
    required this.tabs,
    required this.currentIndexValue,
    required this.targetIndex,
    required this.onTabTapped,
    required this.colorWithOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalTabs = tabs.length;
        final sectionWidth = constraints.maxWidth / totalTabs;

        final stretch = (currentIndexValue - targetIndex).abs().clamp(0.0, 1.0);

        // Увеличиваем базовую ширину, чтобы она была прямоугольной (вытянутой)
        // Теперь базовая ширина 80 (или чуть меньше ширины секции)
        final highlightWidth = (sectionWidth * 0.85) + (30.0 * stretch);
        final highlightHeight = 48.0 - (4.0 * stretch);

        // Идеальное центрирование относительно иконок
        final highlightLeft =
            (sectionWidth * currentIndexValue) +
            (sectionWidth / 2) -
            (highlightWidth / 2);

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
              child: Stack(
                children: [
                  // ИНДИКАТОР (ПРЯМОУГОЛЬНАЯ ВЫТЯНУТАЯ КАПЛЯ)
                  Positioned(
                    left: highlightLeft,
                    top: (62 - highlightHeight) / 2,
                    child: Container(
                      width: highlightWidth,
                      height: highlightHeight,
                      decoration: BoxDecoration(
                        // Используем фиксированный радиус для формы вытянутого прямоугольника
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            colorWithOpacity(Colors.white, 0.25),
                            colorWithOpacity(Colors.white, 0.10),
                          ],
                        ),
                        border: Border.all(
                          color: colorWithOpacity(Colors.white, 0.3),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorWithOpacity(Colors.white, 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ИКОНКИ
                  Row(
                    children: tabs.map((tab) {
                      final distance = (currentIndexValue - tab.index).abs();
                      final t = (1.0 - distance).clamp(0.0, 1.0);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTabTapped(tab.index),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Transform.scale(
                              scale: 1.0 + (0.15 * t),
                              child: SvgPicture.asset(
                                tab.iconPath,
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  Color.lerp(
                                    Colors.white.withOpacity(0.5),
                                    Colors.white,
                                    t,
                                  )!,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabItem {
  final String iconPath;
  final int index;
  _TabItem({required this.iconPath, required this.index});
}

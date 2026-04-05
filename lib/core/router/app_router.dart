import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/ui/home_shell.dart';
import '../../features/home/ui/main_tab.dart';
import '../../features/home/ui/profile_tab.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/programs_list/presentation/ui/programs_screen.dart';
import '../../features/schedule/presentation/ui/schedule_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: RouteNames.splash,
      routes: [
        // ── Splash ───────────────────────────────────────────
        GoRoute(
          name: RouteNames.splashName,
          path: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // ── Login ────────────────────────────────────────────
        GoRoute(
          name: RouteNames.loginName,
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),

        // ── Home (ShellRoute + BottomNav) ────────────────────
        ShellRoute(
          pageBuilder: (context, state, child) => CustomTransitionPage(
            key: state.pageKey,
            child: HomeShell(child: child),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
          routes: [
            GoRoute(
              name: RouteNames.mainName,
              path: RouteNames.main,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MainTab(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              name: RouteNames.programsName,
              path: RouteNames.programs,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProgramsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              name: RouteNames.scheduleName,
              path: RouteNames.schedule,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ScheduleScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
            GoRoute(
              name: RouteNames.profileName,
              path: RouteNames.profile,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileTab(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),
      ],

      // ── Страница ошибки (404) ──────────────────────────────
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Страница не найдена: ${state.uri}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

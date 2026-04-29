import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/features/notifications/ui/notifications_screen.dart';

import '../../features/app_shelll/app_shell.dart';
import '../../features/home/ui/home_tab.dart';
import '../../features/programs/ui/programs_tab.dart';
import '../../features/history/ui/history_screen.dart';
import '../../features/profile/ui/profile_tab.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/schedule/ui/schedule_tab.dart';
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

        // ── ShellRoute ────────────────────────────────────────
        ShellRoute(
          pageBuilder: (context, state, child) => CustomTransitionPage(
            key: state.pageKey,
            child: AppShell(child: child),
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
                transitionsBuilder: (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),

            GoRoute(
              name: RouteNames.programsName,
              path: RouteNames.programs,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProgramsTab(),
                transitionsBuilder: (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),

            GoRoute(
              name: RouteNames.scheduleName,
              path: RouteNames.schedule,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ScheduleTab(),
                transitionsBuilder: (context, animation, _, child) =>
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
                transitionsBuilder: (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),

        // ── Outside ShellRoute ───────────────────────────────
        GoRoute(
          name: RouteNames.historyName,
          path: RouteNames.history,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HistoryScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        ),

        GoRoute(
          name: RouteNames.settingsName,
          path: RouteNames.settings,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        ),

        GoRoute(
          name: RouteNames.notificationsName,
          path: RouteNames.notifications,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const NotificationsScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        ),
      ],

      // ── 404 ───────────────────────────────────────────────
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

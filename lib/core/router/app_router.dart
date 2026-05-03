import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/features/notifications/ui/notifications_screen.dart';
import 'package:hygge_app/features/subscription/ui/account_subscription_page.dart';

import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../features/app/bloc/app_bloc.dart';
import '../../features/app_shelll/app_shell.dart';
import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/home/bloc/home_cubit.dart';
import '../../features/home/ui/home_tab.dart';
import '../../features/history/ui/history_screen.dart';
import '../../features/notifications/bloc/notifications_bloc.dart';
import '../../features/profile/ui/profile_tab.dart';
import '../../features/programs/ui/programs_tab.dart';
import '../../features/schedule/cubit/schedule_cubit.dart';
import '../../features/schedule/ui/schedule_tab.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/subscription/cubit/subscription_cubit.dart';

import 'route_names.dart';

class AppRouter {
  static GoRouter create() {
    final scheduleRepo = ScheduleRepository();
    final bookingRepo = BookingRepository();
    final subscriptionRepo = SubscriptionRepository();

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
          pageBuilder: (context, state, child) {
            final userId =
                context.read<AppBloc>().state.user.uid;

            return CustomTransitionPage(
              key: state.pageKey,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ScheduleCubit>(
                    create: (_) => ScheduleCubit(
                      scheduleRepo: scheduleRepo,
                      bookingRepo: bookingRepo,
                      userId: userId,
                    ),
                  ),
                  BlocProvider<BookingCubit>(
                    create: (_) => BookingCubit(
                      bookingRepo: bookingRepo,
                      subscriptionRepo: subscriptionRepo,
                      userId: userId,
                    ),
                  ),
                  BlocProvider<SubscriptionCubit>(
                    create: (_) => SubscriptionCubit(
                      repository: subscriptionRepo,
                      userId: userId,
                    ),
                  ),
                  BlocProvider<HomeCubit>(
                    create: (_) => HomeCubit(
                      bookingRepo: bookingRepo,
                      scheduleRepo: scheduleRepo,
                      userId: userId,
                    ),
                  ),
                  BlocProvider<NotificationsBloc>(
                    create: (_) => NotificationsBloc()
                      ..add(const NotificationsInitialized()),
                  ),
                ],
                child: AppShell(child: child),
              ),
              transitionsBuilder: (context, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 200),
            );
          },
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

        GoRoute(
          name: RouteNames.subscriptionName,
          path: RouteNames.subscription,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AccountSubscriptionPage(),
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

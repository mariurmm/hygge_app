import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/notification_repository.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app_shell/app_shell.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/history/ui/history_screen.dart';
import 'package:hygge_app/features/home/bloc/home_cubit.dart';
import 'package:hygge_app/features/home/ui/home_tab.dart';
import 'package:hygge_app/features/login/ui/login_screen.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:hygge_app/features/notifications/ui/notifications_screen.dart';
import 'package:hygge_app/features/profile/bloc/profile_bloc.dart';
import 'package:hygge_app/features/profile/ui/profile_tab.dart';
import 'package:hygge_app/features/programs/ui/programs_tab.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_bloc.dart';
import 'package:hygge_app/features/schedule/ui/schedule_tab.dart';
import 'package:hygge_app/features/settings/ui/settings_screen.dart';
import 'package:hygge_app/features/splash/ui/splash_screen.dart';
import 'package:hygge_app/features/subscription/bloc/subscription_bloc.dart';

class AppRouter {
  static GoRouter create() {
    final scheduleRepo = getIt<ScheduleRepository>();
    final bookingRepo = getIt<BookingRepository>();
    final subscriptionRepo = getIt<SubscriptionRepository>();

    return GoRouter(
      initialLocation: RouteNames.splash,
      routes: [
        GoRoute(
          name: RouteNames.splashName,
          path: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          name: RouteNames.loginName,
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          pageBuilder: (context, state, child) {
            final userId = context.read<AppBloc>().state.user.uid;

            return CustomTransitionPage(
              key: state.pageKey,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ScheduleBloc>(
                    create: (_) => ScheduleBloc(
                      scheduleRepo: scheduleRepo,
                    )..add(const ScheduleStarted()),
                  ),
                  BlocProvider<BookingBloc>(
                    create: (_) => BookingBloc(
                      bookingRepo: bookingRepo,
                      subscriptionRepo: subscriptionRepo,
                      whatsAppService: getIt<WhatsAppService>(),
                    ),
                  ),
                  BlocProvider<SubscriptionBloc>(
                    create: (_) => SubscriptionBloc(
                      repository: subscriptionRepo,
                      userId: userId,
                    )..add(const SubscriptionStarted()),
                  ),
                  BlocProvider<HomeCubit>(
                    create: (_) => HomeCubit(
                      bookingRepo: bookingRepo,
                      userId: userId,
                    ),
                  ),
                  BlocProvider<ProfileBloc>(
                    create: (ctx) => ProfileBloc(
                      bookingRepository: ctx.read<BookingRepository>(),
                      scheduleRepository: ctx.read<ScheduleRepository>(),
                      user: ctx.read<AppBloc>().state.user,
                    ),
                  ),
                  BlocProvider<NotificationsBloc>(
                    create: (ctx) => NotificationsBloc(
                      repository: ctx.read<NotificationRepository>(),
                    )..add(const NotificationsInitialized()),
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
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const NotificationsScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        ),
      ],
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

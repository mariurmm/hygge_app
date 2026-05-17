import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/router/app_router.dart';
import 'package:hygge_app/core/theme/app_theme.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app/bloc/locale_cubit.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_bloc.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create();

    return MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesBloc>(
          create: (context) {
            return FavouritesBloc(
              repository: context.read<FavouritesRepository>(),
            )..add(const FavouritesWatchStarted());
          },
        ),
        BlocProvider<ProgramsBloc>(
          create: (context) {
            return ProgramsBloc(
              repository: context.read<ProgramsRepository>(),
            )..add(const ProgramsInitialized());
          },
        ),
        BlocProvider<AppBloc>(
          create: (context) {
            return AppBloc(
              authRepository: context.read<AuthRepository>(),
            );
          },
        ),
        BlocProvider<LocaleCubit>(
          create: (_) {
            final cubit = LocaleCubit();
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LocaleCubit, Locale?>(
            listenWhen: (previous, current) {
              return previous?.languageCode != current?.languageCode;
            },
            listener: (context, locale) {
              final languageCode = locale?.languageCode;

              if (languageCode == null) return;

              context.read<ProgramsBloc>().add(
                ProgramsLocaleChanged(languageCode),
              );
            },
          ),
          BlocListener<ProgramsBloc, ProgramsState>(
            listenWhen: (previous, current) {
              return previous.allPrograms != current.allPrograms;
            },
            listener: (context, state) {
              context.read<FavouritesBloc>().add(
                FavouritesLessonsRegistered(state.allPrograms),
              );
            },
          ),
        ],
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp.router(
              locale: locale,
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light.copyWith(
                platform: TargetPlatform.iOS,
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              scrollBehavior: const NoGlowScrollBehavior(),
              routerConfig: router,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            );
          },
        ),
      ),
    );
  }
}

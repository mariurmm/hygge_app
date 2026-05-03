import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository_impl.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bloc/app_bloc.dart';
import '../bloc/locale_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create();

    return MultiBlocProvider(
      providers: [
        BlocProvider<FavouritesBloc>(
          create: (_) => FavouritesBloc(
            repository: FavouritesRepositoryImpl(),
          )..add(const FavouritesWatchStarted()),
        ),
        BlocProvider(
          create: (context) =>
              AppBloc(authRepository: context.read<AuthRepository>()),
        ),
        BlocProvider(create: (_) => LocaleCubit()..load()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          locale: locale,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light.copyWith(
            platform: TargetPlatform.iOS,
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          scrollBehavior: const CupertinoScrollBehavior(),
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_cubit.dart';

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
        BlocProvider<FavouritesCubit>(create: (_) => FavouritesCubit()),
        BlocProvider(
          create: (_) => AppBloc(authRepository: AuthRepository.instance),
        ),
        BlocProvider(create: (_) => LocaleCubit()..load()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          locale: locale,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // ── Тема с iOS-стилем ─────────────────────────────────
          theme: AppTheme.light.copyWith(
            // Платформа — iOS (убирает android-поведение)
            platform: TargetPlatform.iOS,

            // Убираем ripple/splash эффекты Material
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),

          // ── iOS-физика скролла (без glow) ─────────────────────
          scrollBehavior: const CupertinoScrollBehavior(),

          // ── Навигация ─────────────────────────────────────────
          routerConfig: router,

          // ── Локализация ───────────────────────────────────────
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bloc/app_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create();

    return BlocProvider(
      create: (_) => AppBloc(authRepository: AuthRepository.instance),
      child: MaterialApp.router(
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
    );
  }
}
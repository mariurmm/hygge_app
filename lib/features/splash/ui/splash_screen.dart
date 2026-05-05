import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/features/splash/bloc/splash_bloc.dart';
import 'package:hygge_app/features/splash/widgets/splash_dots_loader.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocProvider(
      create: (ctx) =>
          SplashBloc(authRepository: ctx.read<AuthRepository>())
            ..add(const SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashAuthenticated) context.go(RouteNames.main);
          if (state is SplashUnauthenticated) context.go(RouteNames.login);
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AssetPaths.loginBackground, fit: BoxFit.cover),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetPaths.hyggeLogo,
                      width: AppConstants.splashLogoWidth,
                      height: AppConstants.splashLogoHeight,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacings.sm),
                    Text(loc.appName, style: AppTextStyles.programsHeading),
                    const SizedBox(height: AppSpacings.xl),
                    const SplashDotsLoader(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

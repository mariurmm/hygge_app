import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app/bloc/app_state.dart'
    show AppState, AppStatus;
import 'package:hygge_app/features/profile/bloc/profile_bloc.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_favourites_section.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_history_section.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_programs_header.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_status_section.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/base_layout.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AppBloc, AppState>(
            listenWhen: (p, c) => p.user != c.user,
            listener: (context, state) {
              context.read<ProfileBloc>().syncUser(state.user);
            },
          ),
          BlocListener<AppBloc, AppState>(
            listenWhen: (p, c) => p.status != c.status,
            listener: (context, state) {
              if (state.status == AppStatus.unauthenticated) {
                context.go(RouteNames.login);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final now = DateTime.now();
            final loc = AppLocalizations.of(context);

            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AssetPaths.homeBackground,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned.fill(
                    child: SafeArea(
                      child: HyggeScreenLayout(
                        header: const ProfileProgramsHeader(),
                        onRefresh: () =>
                            context.read<ProfileBloc>().refresh(),
                        children: [
                          ProfileStatusSection(state: state, loc: loc),
                          const ProfileFavouritesSection(),
                          const SizedBox(
                            height: AppSpacings.profileCardsVerticalGap,
                          ),
                          ProfileHistorySection(
                            state: state,
                            now: now,
                            loc: loc,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}

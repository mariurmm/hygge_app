import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app/bloc/app_state.dart'
    show AppState, AppStatus;
import 'package:hygge_app/features/profile/bloc/profile_bloc.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_about_section.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_account_subscription_card.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_history_header.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_monthly_travel_card.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_list.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(user: context.read<AppBloc>().state.user),
      child: MultiBlocListener(
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
            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AssetPaths.homeBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgramsHeader(
                          trailing: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            onPressed: () =>
                                context.push(RouteNames.settings),
                            icon: Image.asset(
                              AssetPaths.settingsIcon,
                              width: AppConstants.programsHeaderIconSize,
                              height: AppConstants.programsHeaderIconSize,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: AppConstants.programsHeaderIconSize,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.profileCardsBottomInset,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppPaddings.profileScreenHorizontal,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.statusLine,
                                    style: AppTextStyles.programsSubtitle,
                                  ),
                                  SizedBox(
                                      height: AppSpacings.profileStatusNameGap),
                                  Text(
                                    state.displayName,
                                    style: AppTextStyles.programsHeading,
                                  ),
                                  SizedBox(
                                      height: AppSpacings.profileNameCardGap),
                                  ProfileAccountSubscriptionCard(
                                    onTap: () {},
                                  ),
                                  SizedBox(
                                      height: AppSpacings.profileCardsVerticalGap),
                                  ProfileMonthlyTravelCard(
                                    percent: state.travelProgressPercent,
                                    description: state.monthlyTravelDescription,
                                    leftSessionsLine: state.leftSessionsLine,
                                    goalLine: state.goalLine,
                                  ),
                                  SizedBox(
                                      height: AppSpacings.profileHistorySectionTop),
                                  ProfileHistoryHeader(
                                    onViewAll: () =>
                                        context.push(RouteNames.history),
                                  ),
                                  SizedBox(
                                      height:
                                          AppSpacings.profileHistoryLinkCardGap),
                                  ProgrammCard(
                                    type: ProgrammCardType.big,
                                    lesson: state.recentSessionLesson,
                                    timingOverlayLabel: state.recentSessionLesson
                                        .historyWhenLabel(now),
                                  ),
                                  SizedBox(
                                      height: AppSpacings.profileCardsVerticalGap),
                                  const ProfileAboutSection(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository_impl.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/home/bloc/home_bloc.dart';
import 'package:hygge_app/features/home/bloc/home_event.dart';
// import 'package:hygge_app/features/home/bloc/home_state.dart';
// import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
// import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/widgets/notification_button.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:hygge_app/widgets/upcoming_programs_list.dart';

import '../../../l10n/generated/app_localizations.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(
        repository: UpcomingLessonRepositoryImpl(),
      )..add(const HomeLoadRequested()),
      child: const _MainTabView(),
    );
  }
}

class _MainTabView extends StatelessWidget {
  const _MainTabView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AssetPaths.homeBackground,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgramsHeader(
                  trailing: notificationIconButton(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.programsCardsBottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                            top: AppSpacings.sm,
                            right: AppPaddings.programsScreenHorizontal,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.programsHeading,
                              children: [
                                TextSpan(text: loc.homeHeadlinePart1),
                                TextSpan(
                                  text: loc.homeHeadlineAccent,
                                  style: AppTextStyles.programsHeading.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.homeHeadlineAccent,
                                  ),
                                ),
                                TextSpan(text: loc.homeHeadlinePart2),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacings.xl),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeAnnouncements,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: AppSpacings.xl,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacings.scheduleSignedTitleGap),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacings.md,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
                            child: Stack(
                              children: [
                                Image.asset(
                                  AssetPaths.homeAnnouncementCard,
                                  width: double.infinity,
                                  height: 218,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: AppSpacings.xl,
                                  bottom: AppSpacings.lg,
                                  child: Text(
                                    loc.readOurNews,
                                    style: AppTextStyles.programsFilter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacings.programsBodyGap),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                            right: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeUpcomingPrograms,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacings.lg),
                        const UpcomingProgramsList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

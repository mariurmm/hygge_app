import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/features/home/bloc/home_cubit.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import '../../../l10n/generated/app_localizations.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

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
                ProgramsHeader(trailing: _NotificationsBell()),
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
                            borderRadius: BorderRadius.circular(
                              AppConstants.programsCardRadius,
                            ),
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
                            style: AppTextStyles.programsHeading
                                .copyWith(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: AppSpacings.lg),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                            if (state.lessons.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppPaddings.programsScreenHorizontal,
                                ),
                                child: Text(
                                  'Нет предстоящих занятий',
                                  style: AppTextStyles.programsSubtitle,
                                ),
                              );
                            }
                            return SizedBox(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppPaddings.programsScreenHorizontal,
                                ),
                                itemCount: state.lessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = state.lessons[index];
                                  final program =
                                      state.programsById[lesson.programId];
                                  if (program == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 14),
                                    child: ProgrammCard(
                                      type: ProgrammCardType.small,
                                      program: program,
                                      lesson: lesson,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
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

class _NotificationsBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationsBloc?>();

    if (bloc == null) {
      return IconButton(
        onPressed: () => context.go('/home/notifications'),
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      );
    }

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.go('/home/notifications'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
            ),
            if (state.hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

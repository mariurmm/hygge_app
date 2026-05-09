import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/home/bloc/home_cubit.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:url_launcher/url_launcher.dart';

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
          Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProgramsHeader(trailing: _NotificationsBell()),
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
                        const SizedBox(
                          height: AppSpacings.scheduleSignedTitleGap,
                        ),
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
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.programsFilter,
                                      children: [
                                        TextSpan(
                                          text: '${loc.readOurNews} ',
                                        ),
                                        TextSpan(
                                          text: '@hy.gge.concept',
                                          style: AppTextStyles.programsFilter
                                              .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              final uri = Uri.parse(
                                                'https://instagram.com/hy.gge.concept',
                                              );

                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
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
                                    padding: const EdgeInsets.only(right: 14),
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
  const _NotificationsBell();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.push(RouteNames.notifications),
      icon: SvgPicture.asset(
        AssetPaths.notificationIcon,
        width: 24,
        height: 24,
      ),
    );
  }
}

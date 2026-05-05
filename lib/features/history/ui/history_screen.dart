import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/features/history/bloc/history_bloc.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocProvider(
      create: (ctx) =>
          HistoryBloc(repository: ctx.read<UpcomingLessonRepository>())
            ..add(const HistoryLoadRequested()),
      child: BlocBuilder<HistoryBloc, HistoryState>(
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
                        leading: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => context.pop(),
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
                                  loc.historyTitle,
                                  style: AppTextStyles.programsHeading,
                                ),
                                const SizedBox(
                                  height: AppSpacings.programsLeadGap,
                                ),
                                Text(
                                  loc.historySubtitle,
                                  style: AppTextStyles.programsSubtitle,
                                ),
                                const SizedBox(
                                  height: AppSpacings.profileHistoryLinkCardGap,
                                ),

                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.lessons.length,
                                  separatorBuilder: (_, __) => const SizedBox(
                                    height: AppSpacings.programsCardsGap,
                                  ),
                                  itemBuilder: (context, index) {
                                    final lesson = state.lessons[index];
                                    final program =
                                        state.programsById[lesson.programId];

                                    if (program == null) {
                                      return const SizedBox.shrink();
                                    }

                                    final master =
                                        state.mastersById[program.trainerId];

                                    return ProgrammCard(
                                      key: ValueKey(lesson.id),
                                      type: ProgrammCardType.big,
                                      program: program,
                                      lesson: lesson,
                                      master: master,
                                      timingOverlayLabel: lesson
                                          .historyWhenLabel(now),
                                    );
                                  },
                                ),
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
    );
  }
}

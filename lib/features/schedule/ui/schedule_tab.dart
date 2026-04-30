import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository_impl.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_program_card.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_progress_card.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_bloc.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_calendar.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleBloc(
        repository: UpcomingLessonRepositoryImpl(),
      )..add(const ScheduleInitialized()),
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          final loc = AppLocalizations.of(context);
          final calendarCells = ScheduleBloc.calendarCells(state.visibleMonth);
          final locale = Localizations.localeOf(context).languageCode;
          final monthLabel = ScheduleBloc.monthLabel(state.visibleMonth, locale);
          final percent = (state.progress * 100).round();
          final scheduledDates = state.scheduledDates;

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
                      const ProgramsHeader(trailing: SizedBox.shrink()),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.scheduleCardsBottomInset,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPaddings.scheduleScreenHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.scheduleTitle,
                                  style: AppTextStyles.scheduleSectionTitle,
                                ),
                                const SizedBox(
                                  height: AppSpacings.programsLeadGap,
                                ),
                                Text(
                                  loc.scheduleMonthlyDescription(monthLabel),
                                  style: AppTextStyles.scheduleDescription,
                                ),
                                const SizedBox(
                                  height: AppSpacings.scheduleCalendarGap,
                                ),
                                ScheduleCalendar(
                                  monthLabel: monthLabel,
                                  cells: calendarCells,
                                  today: state.today,
                                  scheduledDates: scheduledDates,
                                  onPrev: () => context
                                      .read<ScheduleBloc>()
                                      .add(const SchedulePreviousMonthPressed()),
                                  onNext: () => context
                                      .read<ScheduleBloc>()
                                      .add(const ScheduleNextMonthPressed()),
                                ),
                                const SizedBox(
                                  height: AppSpacings.scheduleCalendarGap,
                                ),
                                Text(
                                  loc.scheduleSignedTitle,
                                  style: AppTextStyles.scheduleCalendarTitle,
                                ),
                                const SizedBox(
                                  height: AppSpacings.scheduleSignedTitleGap,
                                ),
                                ...state.bookedLessons.map(
                                  (lesson) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacings.programsCardsGap,
                                    ),
                                    child: ScheduleProgramCard(
                                      ritual: lesson.ritual.isNotEmpty
                                          ? lesson.ritual
                                          : loc.scheduleProgramFallback,
                                      title: lesson.title,
                                      timeRange: lesson.scheduleTimeRange(),
                                      whenLabel: lesson.scheduleDayLabel(
                                        state.today,
                                      ),
                                    ),
                                  ),
                                ),
                                ScheduleProgressCard(
                                  percent: percent,
                                  description: loc.scheduleProgressDescription(
                                    state.completedSessions,
                                    state.totalSessions,
                                  ),
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

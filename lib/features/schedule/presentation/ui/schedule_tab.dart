import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/schedule_program_card.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/schedule_progress_card.dart';
import 'package:hygge_app/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:hygge_app/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:hygge_app/features/schedule/presentation/ui/widgets/schedule_calendar.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleBloc(),
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          final bloc = context.read<ScheduleBloc>();
          final calendarCells = bloc.calendarCells(state.visibleMonth);
          final monthLabel = bloc.monthLabel(state.visibleMonth);
          final percent = (state.progress * 100).round();
          final scheduledDates = state.signedLessons
              .map((lesson) => DateTime(lesson.day.year, lesson.day.month, lesson.day.day))
              .toSet();

          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProgramsHeader(),
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
                                  'Время твоего уединения',
                                  style: AppTextStyles.scheduleSectionTitle,
                                ),
                                const SizedBox(height: AppSpacings.programsLeadGap),
                                Text(
                                  'Спокойные моменты запланированные на $monthLabel.',
                                  style: AppTextStyles.scheduleDescription,
                                ),
                                const SizedBox(height: AppSpacings.scheduleCalendarGap),
                                ScheduleCalendar(
                                  monthLabel: monthLabel,
                                  cells: calendarCells,
                                  today: state.today,
                                  scheduledDates: scheduledDates,
                                  onPrev: bloc.previousMonth,
                                  onNext: bloc.nextMonth,
                                ),
                                const SizedBox(height: AppSpacings.scheduleCalendarGap),
                                Text(
                                  'Записанные',
                                  style: AppTextStyles.scheduleCalendarTitle,
                                ),
                                const SizedBox(
                                  height: AppSpacings.scheduleSignedTitleGap,
                                ),
                                ...state.signedLessons.map(
                                  (lesson) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacings.programsCardsGap,
                                    ),
                                    child: ScheduleProgramCard(
                                      ritual: lesson.ritual,
                                      title: lesson.title,
                                      timeRange: bloc.lessonTimeRange(lesson),
                                      whenLabel: bloc.lessonDayLabel(lesson),
                                    ),
                                  ),
                                ),
                                ScheduleProgressCard(
                                  percent: percent,
                                  description:
                                      'В этом месяце вы завершили ${state.completedSessions} из ${state.totalSessions} сеансов. Придерживайтесь мягкого ритма.',
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

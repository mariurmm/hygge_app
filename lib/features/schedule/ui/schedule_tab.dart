import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository_impl.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_program_card.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_progress_card.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_bloc.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_date_strip.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_empty_state.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';

final class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScheduleBloc>(
      create: (_) => ScheduleBloc(repository: UpcomingLessonRepositoryImpl())..add(const ScheduleStarted()),
      child: const _ScheduleView(),
    );
  }
}

final class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ProgramsHeader(trailing: SizedBox.shrink()),
                Expanded(
                  child: BlocBuilder<ScheduleBloc, ScheduleState>(
                    builder: (BuildContext context, ScheduleState state) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<ScheduleBloc>().add(const ScheduleRefreshRequested());
                        },
                        child: _ScheduleContent(state: state, loc: loc),
                      );
                    },
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

final class _ScheduleContent extends StatelessWidget {
  final ScheduleState state;
  final AppLocalizations loc;

  const _ScheduleContent({required this.state, required this.loc});

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String selectedDateLabel = DateFormat.yMMMMEEEEd(locale).format(state.selectedDay);
    final int percent = (state.progress * 100).round();
    final List<LessonModel> selectedLessons = state.selectedDayLessons;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppConstants.scheduleCardsBottomInset),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPaddings.scheduleScreenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(loc.scheduleTitle, style: AppTextStyles.scheduleSectionTitle),
              const SizedBox(height: AppSpacings.programsLeadGap),
              Text(loc.scheduleMonthlyDescription(selectedDateLabel), style: AppTextStyles.scheduleDescription),
            ],
          ),
        ),
        const SizedBox(height: AppPaddings.largePadding),
        ScheduleDateStrip(
          selectedDay: state.selectedDay,
          onDateSelected: (DateTime day) {
            context.read<ScheduleBloc>().add(ScheduleDaySelected(day));
          },
        ),
        const SizedBox(height: AppPaddings.defaultPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPaddings.scheduleScreenHorizontal),
          child: _ScheduleBody(state: state, loc: loc, percent: percent, selectedLessons: selectedLessons),
        ),
      ],
    );
  }
}

final class _ScheduleBody extends StatelessWidget {
  final ScheduleState state;
  final AppLocalizations loc;
  final int percent;
  final List<LessonModel> selectedLessons;

  const _ScheduleBody({required this.state, required this.loc, required this.percent, required this.selectedLessons});

  @override
  Widget build(BuildContext context) {
    if (state.status == ScheduleStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (state.status == ScheduleStatus.failure) {
      return ScheduleEmptyState(
        title: state.errorMessage ?? loc.scheduleLoadErrorTitle,
        description: loc.scheduleLoadErrorDescription,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(loc.scheduleSignedTitle, style: AppTextStyles.scheduleCalendarTitle),
        const SizedBox(height: AppPaddings.defaultPadding),
        if (selectedLessons.isEmpty)
          ScheduleEmptyState(title: loc.scheduleEmptyTitle, description: loc.scheduleEmptyDescription)
        else
          ...selectedLessons.map((LessonModel lesson) {
            final program = state.programsById[lesson.programId];

            if (program == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacings.programsCardsGap),
              child: ScheduleProgramCard(
                ritual: program.ritual.isNotEmpty ? program.ritual : loc.scheduleProgramFallback,
                title: program.title,
                timeRange: lesson.scheduleTimeRange(),
                whenLabel: lesson.scheduleDayLabel(state.today),
              ),
            );
          }),
        ScheduleProgressCard(
          percent: percent,
          description: loc.scheduleProgressDescription(state.completedSessions, state.totalSessions),
        ),
      ],
    );
  }
}

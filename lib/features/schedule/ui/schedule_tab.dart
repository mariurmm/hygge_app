import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/cubit/booking_cubit.dart';
import 'package:hygge_app/features/booking/ui/class_detail_screen.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_program_card.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_progress_card.dart';
import 'package:hygge_app/features/schedule/cubit/schedule_cubit.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_calendar.dart';
import 'package:hygge_app/features/subscription/cubit/subscription_cubit.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: BlocBuilder<ScheduleCubit, ScheduleState>(
                    builder: (context, state) {
                      final loc = AppLocalizations.of(context);
                      final cubit = context.read<ScheduleCubit>();
                      final calendarCells =
                          cubit.calendarCells(state.visibleMonth);
                      final locale =
                          Localizations.localeOf(context).languageCode;
                      final monthLabel =
                          cubit.monthLabel(state.visibleMonth, locale);
                      final today = state.today;

                      return SingleChildScrollView(
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
                                  height: AppSpacings.programsLeadGap),
                              Text(
                                loc.scheduleMonthlyDescription(monthLabel),
                                style: AppTextStyles.scheduleDescription,
                              ),
                              const SizedBox(
                                  height: AppSpacings.scheduleCalendarGap),
                              ScheduleCalendar(
                                monthLabel: monthLabel,
                                cells: calendarCells,
                                today: today,
                                scheduledDates: state.scheduledDays,
                                onPrev: cubit.previousMonth,
                                onNext: cubit.nextMonth,
                              ),
                              const SizedBox(
                                  height: AppSpacings.scheduleCalendarGap),
                              Text(
                                loc.scheduleSignedTitle,
                                style: AppTextStyles.scheduleCalendarTitle,
                              ),
                              const SizedBox(
                                  height: AppSpacings.scheduleSignedTitleGap),
                              if (state.upcomingClasses.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacings.programsCardsGap),
                                  child: Text(
                                    'Предстоящих занятий нет',
                                    style: AppTextStyles.scheduleCardLabel,
                                  ),
                                )
                              else
                                ...state.upcomingClasses.map(
                                  (cls) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacings.programsCardsGap,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _openClassDetail(context, cls),
                                      child: ScheduleProgramCard(
                                        ritual: cls.type.isNotEmpty
                                            ? cls.type
                                            : loc.scheduleProgramFallback,
                                        title: cls.title,
                                        timeRange: cls.timeRange,
                                        whenLabel: cls.dayLabel(today),
                                      ),
                                    ),
                                  ),
                                ),
                              BlocBuilder<SubscriptionCubit, SubscriptionState>(
                                builder: (context, subState) {
                                  final sub = subState.subscription;
                                  if (sub == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final percent = sub.totalSessions > 0
                                      ? ((sub.usedSessions /
                                                  sub.totalSessions) *
                                              100)
                                          .round()
                                      : 0;
                                  return ScheduleProgressCard(
                                    percent: percent,
                                    description:
                                        loc.scheduleProgressDescription(
                                      sub.usedSessions,
                                      sub.totalSessions,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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

  void _openClassDetail(BuildContext context, ClassModel cls) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<BookingCubit>(),
            ),
            BlocProvider.value(
              value: context.read<SubscriptionCubit>(),
            ),
          ],
          child: ClassDetailScreen(classModel: cls),
        ),
      ),
    );
  }
}

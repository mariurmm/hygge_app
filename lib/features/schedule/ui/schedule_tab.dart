import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/booking/ui/class_detail_screen.dart';
import 'package:hygge_app/features/programs_list/ui/schedule_program_card.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_bloc.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_date_strip.dart';
import 'package:hygge_app/features/schedule/ui/widgets/schedule_empty_state.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:intl/intl.dart';

final class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ProgramsHeader(trailing: SizedBox.shrink()),
                Expanded(
                  child: BlocBuilder<ScheduleBloc, ScheduleState>(
                    builder: (context, state) {
                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        onRefresh: () async {
                          context.read<ScheduleBloc>().add(
                            const ScheduleRefreshRequested(),
                          );
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
  const _ScheduleContent({required this.state, required this.loc});

  final ScheduleState state;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedDateLabel = DateFormat.yMMMMEEEEd(locale)
        .format(state.selectedDay);
    final selectedClasses = state.selectedDayClasses;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPaddings.scheduleScreenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                loc.scheduleTitle,
                style: AppTextStyles.scheduleSectionTitle,
              ),
              const SizedBox(height: AppSpacings.programsLeadGap),
              Text(
                loc.scheduleMonthlyDescription(selectedDateLabel),
                style: AppTextStyles.scheduleDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPaddings.largePadding),
        ScheduleDateStrip(
          selectedDay: state.selectedDay,
          onDateSelected: (day) {
            context.read<ScheduleBloc>().add(ScheduleDaySelected(day));
          },
        ),
        const SizedBox(height: AppPaddings.defaultPadding),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPaddings.scheduleScreenHorizontal,
          ),
          child: _ScheduleBody(
            state: state,
            loc: loc,
            selectedClasses: selectedClasses,
          ),
        ),
      ],
    );
  }
}

final class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody({
    required this.state,
    required this.loc,
    required this.selectedClasses,
  });

  final ScheduleState state;
  final AppLocalizations loc;
  final List<ClassModel> selectedClasses;

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
        title: state.error ?? loc.scheduleLoadErrorTitle,
        description: loc.scheduleLoadErrorDescription,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          loc.scheduleSignedTitle,
          style: AppTextStyles.scheduleCalendarTitle,
        ),
        const SizedBox(height: AppPaddings.defaultPadding),
        if (selectedClasses.isEmpty)
          ScheduleEmptyState(
            title: loc.scheduleEmptyTitle,
            description: loc.scheduleEmptyDescription,
          )
        else
          ...selectedClasses.map((classModel) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacings.programsCardsGap,
                ),
                child: _TappableClassCard(classModel: classModel, loc: loc),
              )),
      ],
    );
  }
}

final class _TappableClassCard extends StatelessWidget {
  const _TappableClassCard({
    required this.classModel,
    required this.loc,
  });

  final ClassModel classModel;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final bookingBloc = context.read<BookingBloc>();
        unawaited(
          Navigator.of(context, rootNavigator: true).push(
            PageRouteBuilder<void>(
              pageBuilder: (_, __, ___) => BlocProvider.value(
                value: bookingBloc,
                child: ClassDetailScreen(classModel: classModel),
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          ),
        );
      },
      child: ScheduleProgramCard(
        ritual: classModel.type.isNotEmpty
            ? classModel.type
            : loc.scheduleProgramFallback,
        title: classModel.title,
        timeRange: classModel.timeRange,
      ),
    );
  }
}
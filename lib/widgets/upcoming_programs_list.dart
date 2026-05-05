import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/home/bloc/home_cubit.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class UpcomingProgramsList extends StatelessWidget {
  const UpcomingProgramsList({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacings.xl),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.lessons.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPaddings.programsScreenHorizontal,
              vertical: AppSpacings.scheduleSignedTitleGap,
            ),
            child: Text(
              loc.homeUpcomingPrograms,
              style: AppTextStyles.programsSubtitle,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPaddings.programsScreenHorizontal,
          ),
          child: Column(
            children: List.generate(state.lessons.length, (index) {
              final lesson = state.lessons[index];
              final program = state.programsById[lesson.programId];

              if (program == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacings.lg),
                child: ProgrammCard(
                  type: ProgrammCardType.big,
                  program: program,
                  lesson: lesson,
                  master: state.mastersById[program.trainerId],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/generated/app_localizations.dart';

enum ProgrammCardType { small, big }

class ProgrammList extends StatelessWidget {
  final ProgrammCardType type;
  final Axis scrollDirection;
  final List<ProgramModel> programs;

  /// Ближайшие занятия по programId.
  /// Если не передать — карточка покажет default duration.
  final Map<String, LessonModel> lessonsByProgramId;

  /// Мастера по masterId.
  /// Если не передать — в details уйдёт MasterModel.empty.
  final Map<String, MasterModel> mastersById;

  const ProgrammList({
    super.key,
    required this.type,
    required this.programs,
    this.lessonsByProgramId = const {},
    this.mastersById = const {},
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return Text(
        AppLocalizations.of(context).noAvailableLessons,
        style: AppTextStyles.settingsLabel16Light,
      );
    }

    if (scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: programs.length,
          padding: const EdgeInsets.only(right: AppSpacings.programsCardsGap),
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacings.programsCardsGap),
          itemBuilder: (context, index) {
            final ProgramModel program = programs[index];

            return ProgrammCard(
              type: type,
              program: program,
              lesson: lessonsByProgramId[program.id],
              master: mastersById[program.trainerId],
            );
          },
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: programs.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacings.programsCardsGap),
      itemBuilder: (context, index) {
        final ProgramModel program = programs[index];

        return ProgrammCard(
          type: type,
          program: program,
          lesson: lessonsByProgramId[program.id],
          master: mastersById[program.trainerId],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';

enum ProgrammCardType { small, big }

class ProgrammList extends StatelessWidget {
  final ProgrammCardType type;
  final Axis scrollDirection;
  final List<LessonModel> lessons;

  const ProgrammList({
    super.key,
    required this.type,
    required this.lessons,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Text('Нет доступных занятий');
    }

    if (scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: 260, // фикс под big card (можно вынести в constants)
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: lessons.length,
          padding: const EdgeInsets.only(right: AppSpacings.programsCardsGap),
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacings.programsCardsGap),
          itemBuilder: (context, index) {
            return ProgrammCard(type: type, lesson: lessons[index]);
          },
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacings.programsCardsGap),
      itemBuilder: (context, index) {
        return ProgrammCard(type: type, lesson: lessons[index]);
      },
    );
  }
}

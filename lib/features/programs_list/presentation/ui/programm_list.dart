import 'package:flutter/material.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_card.dart';

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
    if (scrollDirection == Axis.vertical) {
      return Column(
        children: lessons
            .map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacings.programsCardsGap,
                ),
                child: ProgrammCard(type: type, lesson: lesson),
              ),
            )
            .toList(),
      );
    }
    return ListView.builder(
      scrollDirection: scrollDirection,
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacings.programsCardsGap,
          ),
          child: ProgrammCard(type: type, lesson: lesson),
        );
      },
    );
  }
}

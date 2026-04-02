import 'package:flutter/material.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_list.dart';

class ProgrammCard extends StatelessWidget {
  final ProgrammCardType type;
  final LessonModel lesson;
  const ProgrammCard({super.key, required this.type, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ProgrammCardType.big => Card(
        child: Column(
          children: [
            Text(lesson.title)
          ],
        ),
      ),
      ProgrammCardType.small => Card(
        child: Column(
          children: [
            Text(lesson.title)
          ],
        ),
      ),
    };
  }
}

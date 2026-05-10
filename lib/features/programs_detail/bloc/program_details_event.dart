import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

abstract class ProgramDetailsEvent extends Equatable {
  const ProgramDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ProgramDetailsStarted extends ProgramDetailsEvent {
  const ProgramDetailsStarted({
    required this.program,
    required this.lesson,
    required this.master,
  });

  final ProgramModel program;
  final LessonModel lesson;
  final MasterModel master;

  @override
  List<Object?> get props => [program, lesson, master];
}

class ProgramDetailsLessonSelected extends ProgramDetailsEvent {
  const ProgramDetailsLessonSelected(this.lesson);

  final LessonModel lesson;

  @override
  List<Object?> get props => [lesson];
}

class ProgramDetailsBooked extends ProgramDetailsEvent {
  const ProgramDetailsBooked(this.lesson);

  final LessonModel lesson;

  @override
  List<Object?> get props => [lesson];
}

class ProgramDetailsFavouriteToggled extends ProgramDetailsEvent {
  const ProgramDetailsFavouriteToggled(this.program);

  final ProgramModel program;

  @override
  List<Object?> get props => [program];
}

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
  final ProgramModel program;
  final LessonModel lesson;
  final MasterModel master;

  const ProgramDetailsStarted({
    required this.program,
    required this.lesson,
    required this.master,
  });

  @override
  List<Object?> get props => [program, lesson, master];
}

class ProgramDetailsBooked extends ProgramDetailsEvent {
  final LessonModel lesson;

  const ProgramDetailsBooked(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

class ProgramDetailsFavouriteToggled extends ProgramDetailsEvent {
  final ProgramModel program;

  const ProgramDetailsFavouriteToggled(this.program);

  @override
  List<Object?> get props => [program];
}
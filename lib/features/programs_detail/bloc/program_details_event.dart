import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

abstract class ProgramDetailsEvent extends Equatable {
  const ProgramDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ProgramDetailsStarted extends ProgramDetailsEvent {
  final LessonModel program;

  const ProgramDetailsStarted(this.program);

  @override
  List<Object?> get props => [program];
}

class ProgramDetailsFavouriteToggled extends ProgramDetailsEvent {
  final LessonModel program;

  const ProgramDetailsFavouriteToggled(this.program);

  @override
  List<Object?> get props => [program];
}

class ProgramDetailsBooked extends ProgramDetailsEvent {
  final LessonModel program;

  const ProgramDetailsBooked(this.program);

  @override
  List<Object?> get props => [program];
}

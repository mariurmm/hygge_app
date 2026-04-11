import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

class HistoryState extends Equatable {
  final List<LessonModel> lessons;

  const HistoryState({required this.lessons});

  @override
  List<Object?> get props => [lessons];
}

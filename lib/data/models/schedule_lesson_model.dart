import 'package:equatable/equatable.dart';

class ScheduleLessonModel extends Equatable {
  final String ritual;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final DateTime day;

  const ScheduleLessonModel({
    required this.ritual,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.day,
  });

  @override
  List<Object?> get props => [ritual, title, description, start, end, day];
}

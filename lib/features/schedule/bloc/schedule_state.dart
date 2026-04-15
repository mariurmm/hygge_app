import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

class ScheduleState extends Equatable {
  final DateTime visibleMonth;
  final DateTime today;
  final List<LessonModel> signedLessons;
  final int completedSessions;
  final int totalSessions;

  const ScheduleState({
    required this.visibleMonth,
    required this.today,
    required this.signedLessons,
    required this.completedSessions,
    required this.totalSessions,
  });

  double get progress => totalSessions == 0 ? 0 : completedSessions / totalSessions;

  ScheduleState copyWith({
    DateTime? visibleMonth,
    DateTime? today,
    List<LessonModel>? signedLessons,
    int? completedSessions,
    int? totalSessions,
  }) {
    return ScheduleState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      today: today ?? this.today,
      signedLessons: signedLessons ?? this.signedLessons,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  @override
  List<Object?> get props => [
        visibleMonth,
        today,
        signedLessons,
        completedSessions,
        totalSessions,
      ];
}

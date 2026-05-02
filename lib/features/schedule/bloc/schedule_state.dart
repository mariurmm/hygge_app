import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

/// Loading lifecycle for the schedule screen.
enum ScheduleStatus { initial, loading, loaded, failure }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final DateTime visibleMonth;
  final DateTime today;
  final List<LessonModel> bookedLessons;
  final List<LessonModel> completedLessons;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    required this.visibleMonth,
    required this.today,
    this.bookedLessons = const [],
    this.completedLessons = const [],
    this.errorMessage,
  });

  /// All lessons the user ever signed up for (booked + completed).
  List<LessonModel> get allLessons => [...bookedLessons, ...completedLessons];

  int get completedSessions => completedLessons.length;
  int get totalSessions => bookedLessons.length + completedLessons.length;

  double get progress =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;

  /// All booked dates as a [Set] (for calendar dot highlighting).
  Set<DateTime> get scheduledDates =>
      bookedLessons.map((l) => l.calendarDay).toSet();

  /// Booked lessons that fall on [day].
  List<LessonModel> lessonsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return bookedLessons.where((l) => l.calendarDay == d).toList();
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    DateTime? visibleMonth,
    DateTime? today,
    List<LessonModel>? bookedLessons,
    List<LessonModel>? completedLessons,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      visibleMonth: visibleMonth ?? this.visibleMonth,
      today: today ?? this.today,
      bookedLessons: bookedLessons ?? this.bookedLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        visibleMonth,
        today,
        bookedLessons,
        completedLessons,
        errorMessage,
      ];
}

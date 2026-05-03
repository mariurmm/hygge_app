import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

enum ScheduleStatus { initial, loading, success, failure }

final class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final DateTime today;
  final DateTime selectedDay;
  final List<LessonModel> bookedLessons;
  final List<LessonModel> completedLessons;
  final String? errorMessage;
  final Map<String, ProgramModel> programsById;

  const ScheduleState({
    required this.today,
    required this.selectedDay,
    this.status = ScheduleStatus.initial,
    this.bookedLessons = const <LessonModel>[],
    this.completedLessons = const <LessonModel>[],
    this.errorMessage,
    this.programsById = const {},
  });

  factory ScheduleState.initial() {
    final DateTime now = DateTime.now();
    final DateTime today = _dayOnly(now);

    return ScheduleState(today: today, selectedDay: today);
  }

  List<LessonModel> get allLessons => <LessonModel>[
    ...bookedLessons,
    ...completedLessons,
  ];

  int get completedSessions => completedLessons.length;

  int get totalSessions => bookedLessons.length + completedLessons.length;

  double get progress =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;

  Set<DateTime> get scheduledDates => bookedLessons
      .map((LessonModel lesson) => _dayOnly(lesson.calendarDay))
      .toSet();

  List<LessonModel> get selectedDayLessons {
    final DateTime selected = _dayOnly(selectedDay);

    final List<LessonModel> lessons = bookedLessons
        .where((LessonModel lesson) => _dayOnly(lesson.calendarDay) == selected)
        .toList(growable: false);

    return lessons..sort(
      (LessonModel a, LessonModel b) => a.startDate.compareTo(b.startDate),
    );
  }

  bool get hasSelectedDayLessons => selectedDayLessons.isNotEmpty;

  ScheduleState copyWith({
    ScheduleStatus? status,
    DateTime? today,
    DateTime? selectedDay,
    List<LessonModel>? bookedLessons,
    List<LessonModel>? completedLessons,
    String? errorMessage,
    bool clearError = false,
    Map<String, ProgramModel>? programsById,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      today: today ?? this.today,
      selectedDay: selectedDay ?? this.selectedDay,
      bookedLessons: bookedLessons ?? this.bookedLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      programsById: programsById ?? this.programsById,
    );
  }

  static DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  List<Object?> get props => <Object?>[
    status,
    today,
    selectedDay,
    bookedLessons,
    completedLessons,
    errorMessage,
    programsById,
  ];
}

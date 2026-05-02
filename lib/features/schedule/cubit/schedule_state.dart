part of 'schedule_cubit.dart';

class ScheduleState extends Equatable {
  final DateTime visibleMonth;
  final DateTime today;
  final List<ClassModel> upcomingClasses;
  final List<ClassModel> monthClasses;
  final String? error;

  const ScheduleState({
    required this.visibleMonth,
    required this.today,
    this.upcomingClasses = const [],
    this.monthClasses = const [],
    this.error,
  });

  Set<DateTime> get scheduledDays =>
      monthClasses.map((c) => c.calendarDay).toSet();

  ScheduleState copyWith({
    DateTime? visibleMonth,
    DateTime? today,
    List<ClassModel>? upcomingClasses,
    List<ClassModel>? monthClasses,
    String? error,
  }) {
    return ScheduleState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      today: today ?? this.today,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      monthClasses: monthClasses ?? this.monthClasses,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [visibleMonth, today, upcomingClasses, monthClasses, error];
}

part of 'schedule_bloc.dart';

enum ScheduleStatus { initial, loading, success, failure }

final class ScheduleState extends Equatable {
  const ScheduleState({
    required this.today,
    required this.selectedDay,
    this.status = ScheduleStatus.initial,
    this.upcomingClasses = const [],
    this.monthClasses = const [],
    this.error,
  });

  factory ScheduleState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ScheduleState(today: today, selectedDay: today);
  }

  final ScheduleStatus status;
  final DateTime today;
  final DateTime selectedDay;
  final List<ClassModel> upcomingClasses;
  final List<ClassModel> monthClasses;
  final String? error;

  List<ClassModel> get selectedDayClasses {
    final selected = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    return upcomingClasses
        .where((c) => c.calendarDay == selected)
        .toList(growable: false)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    DateTime? today,
    DateTime? selectedDay,
    List<ClassModel>? upcomingClasses,
    List<ClassModel>? monthClasses,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      today: today ?? this.today,
      selectedDay: selectedDay ?? this.selectedDay,
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      monthClasses: monthClasses ?? this.monthClasses,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        today,
        selectedDay,
        upcomingClasses,
        monthClasses,
        error,
      ];
}
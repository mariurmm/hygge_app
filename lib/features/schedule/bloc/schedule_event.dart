part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleStarted extends ScheduleEvent {
  const ScheduleStarted();
}

final class ScheduleRefreshRequested extends ScheduleEvent {
  const ScheduleRefreshRequested();
}

final class ScheduleDaySelected extends ScheduleEvent {
  const ScheduleDaySelected(this.day);
  final DateTime day;

  @override
  List<Object?> get props => [day];
}

final class _UpcomingClassesUpdated extends ScheduleEvent {
  const _UpcomingClassesUpdated(this.classes);
  final List<ClassModel> classes;

  @override
  List<Object?> get props => [classes];
}

final class _MonthClassesUpdated extends ScheduleEvent {
  const _MonthClassesUpdated(this.classes);
  final List<ClassModel> classes;

  @override
  List<Object?> get props => [classes];
}

final class _ScheduleErrorOccurred extends ScheduleEvent {
  const _ScheduleErrorOccurred(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}

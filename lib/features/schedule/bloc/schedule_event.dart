part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ScheduleStarted extends ScheduleEvent {
  const ScheduleStarted();
}

final class ScheduleRefreshRequested extends ScheduleEvent {
  const ScheduleRefreshRequested();
}

final class ScheduleDaySelected extends ScheduleEvent {
  final DateTime day;

  const ScheduleDaySelected(this.day);

  @override
  List<Object?> get props => <Object?>[day];
}

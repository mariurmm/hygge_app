part of 'schedule_bloc.dart';

sealed class ScheduleEvent {
  const ScheduleEvent();
}

/// Load booked + completed lessons from the repository.
final class ScheduleInitialized extends ScheduleEvent {
  const ScheduleInitialized();
}

/// Re-fetch bookings (e.g. after returning from a booking flow).
final class ScheduleRefreshRequested extends ScheduleEvent {
  const ScheduleRefreshRequested();
}

final class ScheduleNextMonthPressed extends ScheduleEvent {
  const ScheduleNextMonthPressed();
}

final class SchedulePreviousMonthPressed extends ScheduleEvent {
  const SchedulePreviousMonthPressed();
}

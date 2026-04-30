import 'package:bloc/bloc.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';
import 'package:intl/intl.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

part 'schedule_event.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc({required UpcomingLessonRepository repository})
      : _repository = repository,
        super(
          ScheduleState(
            visibleMonth:
                DateTime(DateTime.now().year, DateTime.now().month, 1),
            today: DateTime.now(),
          ),
        ) {
    on<ScheduleInitialized>(_onInitialized);
    on<ScheduleRefreshRequested>(_onRefresh);
    on<ScheduleNextMonthPressed>(_onNextMonth);
    on<SchedulePreviousMonthPressed>(_onPreviousMonth);
  }

  final UpcomingLessonRepository _repository;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
    ScheduleInitialized event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    await _loadBookings(emit);
  }

  Future<void> _onRefresh(
    ScheduleRefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await _loadBookings(emit);
  }

  Future<void> _loadBookings(Emitter<ScheduleState> emit) async {
    try {
      final booked = await _repository.fetchBookings(status: 'booked');
      final completed = await _repository.fetchBookings(status: 'completed');

      emit(
        state.copyWith(
          status: ScheduleStatus.loaded,
          bookedLessons: booked,
          completedLessons: completed,
          today: DateTime.now(),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'Failed to load schedule',
        ),
      );
    }
  }

  void _onNextMonth(
    ScheduleNextMonthPressed event,
    Emitter<ScheduleState> emit,
  ) {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month + 1, 1)));
  }

  void _onPreviousMonth(
    SchedulePreviousMonthPressed event,
    Emitter<ScheduleState> emit,
  ) {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month - 1, 1)));
  }

  // ── Pure utilities (no state dependency) ──────────────────────────────────

  /// Formatted month label, e.g. "April 2026".
  static String monthLabel(DateTime month, [String locale = 'en']) =>
      DateFormat('LLLL yyyy', locale).format(month);

  /// Calendar grid cells for a given [month], padded to full weeks.
  static List<DateTime?> calendarCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';

part 'schedule_event.dart';

final class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final UpcomingLessonRepository _repository;

  ScheduleBloc({required UpcomingLessonRepository repository})
    : _repository = repository,
      super(ScheduleState.initial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleRefreshRequested>(_onRefreshRequested);
    on<ScheduleDaySelected>(_onScheduleDaySelected);
  }

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    ScheduleRefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  void _onScheduleDaySelected(
    ScheduleDaySelected event,
    Emitter<ScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDay: DateTime(event.day.year, event.day.month, event.day.day),
      ),
    );
  }

  Future<void> _load(
    Emitter<ScheduleState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: ScheduleStatus.loading, clearError: true));
    }

    try {
      final List<List<LessonModel>> results =
          await Future.wait<List<LessonModel>>(<Future<List<LessonModel>>>[
            _repository.fetchBookings(status: 'booked'),
            _repository.fetchBookings(status: 'completed'),
          ]);

      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          today: _dayOnly(DateTime.now()),
          bookedLessons: results[0],
          completedLessons: results[1],
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'Не удалось загрузить расписание',
        ),
      );
    }
  }

  static DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

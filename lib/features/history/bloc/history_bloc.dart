import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required UpcomingLessonRepository repository})
      : _repository = repository,
        super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  final UpcomingLessonRepository _repository;

  static const String _completedStatus = 'completed';

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final lessons = await _repository.fetchBookings(status: _completedStatus);
      emit(state.copyWith(status: HistoryStatus.success, lessons: lessons));
    } on Exception {
      emit(state.copyWith(status: HistoryStatus.failure));
    }
  }
}
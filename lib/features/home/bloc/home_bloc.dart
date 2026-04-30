import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required UpcomingLessonRepository repository})
      : _repository = repository,
        super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
  }

  final UpcomingLessonRepository _repository;

  static const int _upcomingLimit = 10;

  Future<void> _onLoad(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final lessons = await _repository.fetchUpcomingPrograms(
        limit: _upcomingLimit,
      );
      emit(state.copyWith(lessons: lessons, isLoading: false));
    } on Exception {
      emit(state.copyWith(lessons: const [], isLoading: false));
    }
  }
}
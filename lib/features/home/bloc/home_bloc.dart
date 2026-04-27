import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
  }

  final FirebaseFeatureRepository _repository;

  Future<void> _onLoad(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final lessons = await _repository.fetchPrograms(limit: 4);
      emit(state.copyWith(lessons: lessons, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }
}

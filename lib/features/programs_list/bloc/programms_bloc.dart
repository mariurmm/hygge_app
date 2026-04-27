import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

abstract class ProgrammsState {}

class ProgrammsLoadingState extends ProgrammsState {}

class ProgrammLoadedState extends ProgrammsState {
  final List<LessonModel> lessons;
  final Set<String> favoriteIds;

  ProgrammLoadedState({required this.lessons, this.favoriteIds = const {}});

  ProgrammLoadedState copyWith({
    List<LessonModel>? lessons,
    Set<String>? favoriteIds,
  }) {
    return ProgrammLoadedState(
      lessons: lessons ?? this.lessons,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

abstract class ProgrammsEvent {}

class ProgrammsLoadEvent extends ProgrammsEvent {}

class ProgrammsBloc extends Bloc<ProgrammsEvent, ProgrammsState> {
  ProgrammsBloc({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(ProgrammsLoadingState()) {
    on<ProgrammsLoadEvent>(_onLoad);
  }

  final FirebaseFeatureRepository _repository;

  FutureOr<void> _onLoad(
    ProgrammsLoadEvent event,
    Emitter<ProgrammsState> emit,
  ) async {
    final lessons = await _repository.fetchPrograms();
    final favoriteIds = await _repository.fetchFavouriteIds();
    emit(ProgrammLoadedState(lessons: lessons, favoriteIds: favoriteIds));
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository_impl.dart';

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
  ProgrammsBloc({
    ProgramsRepository? programsRepository,
    FavouritesRepository? favouritesRepository,
  })  : _programsRepository = programsRepository ?? ProgramsRepositoryImpl(),
        _favouritesRepository = favouritesRepository ?? FavouritesRepositoryImpl(),
        super(ProgrammsLoadingState()) {
    on<ProgrammsLoadEvent>(_onLoad);
  }

  final ProgramsRepository _programsRepository;
  final FavouritesRepository _favouritesRepository;

  FutureOr<void> _onLoad(
    ProgrammsLoadEvent event,
    Emitter<ProgrammsState> emit,
  ) async {
    final lessons = await _programsRepository.fetchPrograms();
    final favoriteIds = await _favouritesRepository.fetchFavouriteIds();
    emit(ProgrammLoadedState(lessons: lessons, favoriteIds: favoriteIds));
  }
}

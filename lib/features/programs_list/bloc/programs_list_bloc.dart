import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository_impl.dart';

abstract class ProgramsListState {}

class ProgramsListLoadingState extends ProgramsListState {}

class ProgramsListLoadedState extends ProgramsListState {
  final List<ProgramModel> lessons;
  final Set<String> favoriteIds;

  ProgramsListLoadedState({required this.lessons, this.favoriteIds = const {}});

  ProgramsListLoadedState copyWith({List<ProgramModel>? lessons, Set<String>? favoriteIds}) {
    return ProgramsListLoadedState(lessons: lessons ?? this.lessons, favoriteIds: favoriteIds ?? this.favoriteIds);
  }
}

abstract class ProgramsListEvent {}

class ProgramsListLoadEvent extends ProgramsListEvent {}

class ProgramsListBloc extends Bloc<ProgramsListEvent, ProgramsListState> {
  ProgramsListBloc({ProgramsRepository? programsRepository, FavouritesRepository? favouritesRepository})
    : _programsRepository = programsRepository ?? ProgramsRepositoryImpl(),
      _favouritesRepository = favouritesRepository ?? FavouritesRepositoryImpl(),
      super(ProgramsListLoadingState()) {
    on<ProgramsListLoadEvent>(_onLoad);
  }

  final ProgramsRepository _programsRepository;
  final FavouritesRepository _favouritesRepository;

  FutureOr<void> _onLoad(ProgramsListLoadEvent event, Emitter<ProgramsListState> emit) async {
    final lessons = await _programsRepository.fetchPrograms();
    final favoriteIds = await _favouritesRepository.fetchFavouriteIds();
    emit(ProgramsListLoadedState(lessons: lessons, favoriteIds: favoriteIds));
  }
}

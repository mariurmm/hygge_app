import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  FavouritesBloc({required FavouritesRepository repository})
      : _repository = repository,
        super(const FavouritesState()) {
    on<FavouritesWatchStarted>(_onWatchStarted);
    on<FavouritesToggled>(_onToggled);
    on<FavouritesLessonsRegistered>(_onLessonsRegistered);
    on<_FavouriteIdsUpdated>(_onIdsUpdated);
  }

  final FavouritesRepository _repository;
  StreamSubscription<Set<String>>? _subscription;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onWatchStarted(
    FavouritesWatchStarted event,
    Emitter<FavouritesState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.watchFavouriteIds().listen(
      (ids) => add(_FavouriteIdsUpdated(ids)),
    );
  }

  void _onIdsUpdated(
    _FavouriteIdsUpdated event,
    Emitter<FavouritesState> emit,
  ) {
    emit(state.copyWith(favouriteIds: event.ids));
  }

  Future<void> _onToggled(
    FavouritesToggled event,
    Emitter<FavouritesState> emit,
  ) async {
    final shouldAdd = !state.favouriteIds.contains(event.uuid);
    final updated = Set<String>.from(state.favouriteIds);

    shouldAdd ? updated.add(event.uuid) : updated.remove(event.uuid);

    // Optimistic update.
    emit(state.copyWith(favouriteIds: updated));

    await _repository.setFavourite(
      programId: event.uuid,
      isFavourite: shouldAdd,
    );
  }

  void _onLessonsRegistered(
    FavouritesLessonsRegistered event,
    Emitter<FavouritesState> emit,
  ) {
    emit(state.copyWith(allLessons: event.lessons));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

}
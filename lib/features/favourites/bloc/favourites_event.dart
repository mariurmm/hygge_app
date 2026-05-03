part of 'favourites_bloc.dart';

abstract class FavouritesEvent extends Equatable {
  const FavouritesEvent();

  @override
  List<Object?> get props => [];
}

class FavouritesWatchStarted extends FavouritesEvent {
  const FavouritesWatchStarted();
}

class FavouritesToggled extends FavouritesEvent {
  final String uuid;

  const FavouritesToggled(this.uuid);

  @override
  List<Object?> get props => [uuid];
}

class FavouritesLessonsRegistered extends FavouritesEvent {
  final List<ProgramModel> programs;

  const FavouritesLessonsRegistered(this.programs);

  @override
  List<Object?> get props => [programs];
}

class _FavouriteIdsUpdated extends FavouritesEvent {
  final Set<String> ids;

  const _FavouriteIdsUpdated(this.ids);

  @override
  List<Object?> get props => [ids];
}

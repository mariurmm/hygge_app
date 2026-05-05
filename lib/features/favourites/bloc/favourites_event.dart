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
  const FavouritesToggled(this.uuid);
  final String uuid;

  @override
  List<Object?> get props => [uuid];
}

class FavouritesLessonsRegistered extends FavouritesEvent {
  const FavouritesLessonsRegistered(this.programs);
  final List<ProgramModel> programs;

  @override
  List<Object?> get props => [programs];
}

class _FavouriteIdsUpdated extends FavouritesEvent {
  const _FavouriteIdsUpdated(this.ids);
  final Set<String> ids;

  @override
  List<Object?> get props => [ids];
}

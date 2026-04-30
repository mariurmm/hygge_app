part of 'favourites_bloc.dart';

sealed class FavouritesEvent {
  const FavouritesEvent();
}

/// Start watching favourite IDs from the repository.
final class FavouritesWatchStarted extends FavouritesEvent {
  const FavouritesWatchStarted();
}

/// Toggle favourite status for a given program UUID.
final class FavouritesToggled extends FavouritesEvent {
  const FavouritesToggled(this.uuid);
  final String uuid;
}

/// Register all loaded lessons so favouriteLessons can be computed.
final class FavouritesLessonsRegistered extends FavouritesEvent {
  const FavouritesLessonsRegistered(this.lessons);
  final List<LessonModel> lessons;
}

/// Internal — emitted when the stream pushes a new set of IDs.
final class _FavouriteIdsUpdated extends FavouritesEvent {
  const _FavouriteIdsUpdated(this.ids);
  final Set<String> ids;
}
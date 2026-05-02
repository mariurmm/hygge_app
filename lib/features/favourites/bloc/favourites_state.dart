part of 'favourites_bloc.dart';

final class FavouritesState extends Equatable {
  const FavouritesState({
    this.favouriteIds = const {},
    this.allLessons = const [],
  });

  final Set<String> favouriteIds;
  final List<LessonModel> allLessons;

  List<LessonModel> get favouriteLessons =>
      allLessons.where((l) => favouriteIds.contains(l.uuid)).toList();

  bool isFavourite(String uuid) => favouriteIds.contains(uuid);

  FavouritesState copyWith({
    Set<String>? favouriteIds,
    List<LessonModel>? allLessons,
  }) =>
      FavouritesState(
        favouriteIds: favouriteIds ?? this.favouriteIds,
        allLessons: allLessons ?? this.allLessons,
      );

  @override
  List<Object?> get props => [favouriteIds, allLessons];
}
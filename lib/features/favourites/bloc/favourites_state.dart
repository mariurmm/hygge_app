part of 'favourites_bloc.dart';

class FavouritesState extends Equatable {
  final Set<String> favouriteIds;
  final List<ProgramModel> allPrograms;

  const FavouritesState({
    this.favouriteIds = const {},
    this.allPrograms = const [],
  });

  bool isFavourite(String programId) {
    return favouriteIds.contains(programId);
  }

  List<ProgramModel> get favouritePrograms {
    return allPrograms
        .where((program) => favouriteIds.contains(program.id))
        .toList();
  }

  FavouritesState copyWith({
    Set<String>? favouriteIds,
    List<ProgramModel>? allPrograms,
  }) {
    return FavouritesState(
      favouriteIds: favouriteIds ?? this.favouriteIds,
      allPrograms: allPrograms ?? this.allPrograms,
    );
  }

  @override
  List<Object?> get props => [favouriteIds, allPrograms];
}

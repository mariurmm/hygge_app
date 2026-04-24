// import 'package:equatable/equatable.dart';
// import 'package:hygge_app/data/models/lesson_model.dart';

// class FavouritesState extends Equatable {
//   /// UUID-и избранных занятий.
//   final Set<String> favouriteIds;

//   /// Все занятия, загруженные в приложении.
//   final List<LessonModel> allLessons;

//   const FavouritesState({
//     this.favouriteIds = const {},
//     this.allLessons = const [],
//   });

//   /// Вычисляемый список избранных занятий.
//   List<LessonModel> get favouriteLessons =>
//       allLessons.where((l) => favouriteIds.contains(l.uuid)).toList();

//   bool isFavourite(String uuid) => favouriteIds.contains(uuid);

//   FavouritesState copyWith({
//     Set<String>? favouriteIds,
//     List<LessonModel>? allLessons,
//   }) {
//     return FavouritesState(
//       favouriteIds: favouriteIds ?? this.favouriteIds,
//       allLessons: allLessons ?? this.allLessons,
//     );
//   }

//   @override
//   List<Object?> get props => [favouriteIds, allLessons];
// }
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

class FavouritesState extends Equatable {
  final Set<String> favouriteIds;
  final List<LessonModel> allLessons;

  const FavouritesState({
    this.favouriteIds = const {},
    this.allLessons = const [],
  });

  List<LessonModel> get favouriteLessons {
    final result = allLessons
        .where((l) => favouriteIds.contains(l.uuid))
        .toList();

    print('COMPUTED FAV LESSONS: ${result.length}');
    return result;
  }

  bool isFavourite(String uuid) => favouriteIds.contains(uuid);

  FavouritesState copyWith({
    Set<String>? favouriteIds,
    List<LessonModel>? allLessons,
  }) {
    return FavouritesState(
      favouriteIds: favouriteIds ?? this.favouriteIds,
      allLessons: allLessons ?? this.allLessons,
    );
  }

  @override
  List<Object?> get props => [favouriteIds, allLessons];
}

// import 'package:bloc/bloc.dart';
// import 'package:hygge_app/data/models/lesson_model.dart';
// import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';

// /// Управляет избранными программами.
// /// Хранит только UUID и список всех уроков.
// /// UI получает вычисляемые favouriteLessons.
// class FavouritesCubit extends Cubit<FavouritesState> {
//   FavouritesCubit() : super(const FavouritesState());

//   /// Переключает избранное состояние урока.
//   void toggle(String uuid) {
//     final updatedIds = Set<String>.from(state.favouriteIds);

//     if (updatedIds.contains(uuid)) {
//       updatedIds.remove(uuid);
//     } else {
//       updatedIds.add(uuid);
//     }

//     emit(state.copyWith(favouriteIds: updatedIds));
//   }

//   /// Регистрирует полный список уроков.
//   /// Вызывается из ProgramsBloc.
//   void registerLessons(List<LessonModel> lessons) {
//     emit(state.copyWith(allLessons: lessons));
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit() : super(const FavouritesState());

  void toggle(String uuid) {
    final updated = Set<String>.from(state.favouriteIds);

    if (updated.contains(uuid)) {
      updated.remove(uuid);
      print('FAV TOGGLE: REMOVE $uuid');
    } else {
      updated.add(uuid);
      print('FAV TOGGLE: ADD $uuid');
    }

    emit(state.copyWith(favouriteIds: updated));

    print('FAV IDS AFTER TOGGLE: ${updated.toList()}');
    print('FAV LESSONS COUNT: ${state.favouriteLessons.length}');
  }

  void registerLessons(List<LessonModel> lessons) {
    print('REGISTER LESSONS: ${lessons.length}');

    emit(state.copyWith(allLessons: lessons));

    print('ALL LESSONS UPDATED: ${state.allLessons.length}');
    print('FAV LESSONS AFTER REGISTER: ${state.favouriteLessons.length}');
  }
}

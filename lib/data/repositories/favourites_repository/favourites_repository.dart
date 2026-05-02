import 'package:hygge_app/data/models/lesson_model.dart';

abstract class FavouritesRepository {
  Stream<Set<String>> watchFavouriteIds();
  Future<Set<String>> fetchFavouriteIds();
  Future<void> setFavourite({
    required String programId,
    required bool isFavourite,
  });
  Future<List<LessonModel>> fetchFavouritePrograms();
}
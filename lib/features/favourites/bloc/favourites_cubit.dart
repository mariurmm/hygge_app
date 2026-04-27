import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(const FavouritesState()) {
    _subscription = _repository.watchFavouriteIds().listen((ids) {
      emit(state.copyWith(favouriteIds: ids));
    });
  }

  final FirebaseFeatureRepository _repository;
  StreamSubscription<Set<String>>? _subscription;

  Future<void> toggle(String uuid) async {
    final updated = Set<String>.from(state.favouriteIds);
    final shouldAdd = !updated.contains(uuid);

    if (shouldAdd) {
      updated.add(uuid);
    } else {
      updated.remove(uuid);
    }

    emit(state.copyWith(favouriteIds: updated));
    await _repository.setFavourite(programId: uuid, isFavourite: shouldAdd);
  }

  void registerLessons(List<LessonModel> lessons) {
    emit(state.copyWith(allLessons: lessons));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

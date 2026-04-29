import 'package:bloc/bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_state.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class ProgramsBloc extends Cubit<ProgramsState> {
  ProgramsBloc({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(const ProgramsState()) {
    _loadLessons();
  }

  final FirebaseFeatureRepository _repository;

  void selectFilter(int index) {
    if (index < 0 || index >= ProgramsFilter.values.length) return;
    emit(state.copyWith(selectedFilter: ProgramsFilter.values[index]));
  }

  Future<void> _loadLessons() async {
    final lessons = await _repository.fetchPrograms();
    emit(state.copyWith(allLessons: lessons));
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';

part 'programs_event.dart';
part 'programs_state.dart';

class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  ProgramsBloc({ProgramsRepository? repository})
    : _repository = repository ?? ProgramsRepositoryImpl(),
      super(const ProgramsState()) {
    on<ProgramsInitialized>(_onInitialized);
    on<ProgramsFilterChanged>(_onFilterChanged);
  }

  final ProgramsRepository _repository;

  Future<void> _onInitialized(
    ProgramsInitialized event,
    Emitter<ProgramsState> emit,
  ) async {
    try {
      final lessons = await _repository.fetchPrograms();
      emit(state.copyWith(allLessons: lessons));
    } catch (e) {
      emit(state.copyWith(allLessons: const []));
    }
  }

  Future<void> _onFilterChanged(
    ProgramsFilterChanged event,
    Emitter<ProgramsState> emit,
  ) async {
    if (event.filterIndex < 0 ||
        event.filterIndex >= ProgramsFilter.values.length) {
      return;
    }
    emit(
      state.copyWith(selectedFilter: ProgramsFilter.values[event.filterIndex]),
    );
  }

  void selectFilter(int index) {
    add(ProgramsFilterChanged(index));
  }
}

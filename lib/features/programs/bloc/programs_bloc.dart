import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_category.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';

part 'programs_event.dart';
part 'programs_state.dart';

class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  ProgramsBloc({
    required ProgramsRepository repository,
    FirebaseFirestore? firestore,
  }) : _repository = repository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const ProgramsState()) {
    on<ProgramsInitialized>((_, emit) => _load(emit));
    on<ProgramsRefreshRequested>((_, emit) => _load(emit));
    on<ProgramsFilterChanged>(_onFilterChanged);
  }
  final ProgramsRepository _repository;
  final FirebaseFirestore _firestore;

  Future<void> _load(Emitter<ProgramsState> emit) async {
    try {
      final programs = await _repository.fetchPrograms();
      AppLogger.debug('ProgramsBloc: загружено ${programs.length} программ');
      final nearestLessonsByProgramId = await _fetchNearestLessons(programs);
      final mastersById = await _fetchMasters(programs);

      emit(
        state.copyWith(
          allPrograms: programs,
          nearestLessonsByProgramId: nearestLessonsByProgramId,
          mastersById: mastersById,
        ),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProgramsBloc: ошибка загрузки программ',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          allPrograms: const [],
          nearestLessonsByProgramId: const {},
          mastersById: const {},
        ),
      );
    }
  }

  Future<void> _onFilterChanged(
    ProgramsFilterChanged event,
    Emitter<ProgramsState> emit,
  ) async {
    if (event.filterIndex < 0 ||
        event.filterIndex >= ProgramFilter.values.length) {
      return;
    }

    emit(
      state.copyWith(selectedFilter: ProgramFilter.values[event.filterIndex]),
    );
  }

  Future<Map<String, LessonModel>> _fetchNearestLessons(
    List<ProgramModel> programs,
  ) async {
    final now = Timestamp.fromDate(DateTime.now());
    final result = <String, LessonModel>{};

    for (final program in programs) {
      final snapshot = await _firestore
          .collection('lessons')
          .where('programId', isEqualTo: program.id)
          .where('startDate', isGreaterThanOrEqualTo: now)
          .orderBy('startDate')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) continue;

      final doc = snapshot.docs.first;
      final lesson = LessonModel.fromJson({...doc.data(), 'id': doc.id});

      result[program.id] = lesson;
    }

    return result;
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    List<ProgramModel> programs,
  ) async {
    final trainerIds = programs
        .map((program) => program.trainerId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, MasterModel>{};

    for (final trainerId in trainerIds) {
      final doc = await _firestore.collection('masters').doc(trainerId).get();
      final data = doc.data();

      if (!doc.exists || data == null) continue;

      final master = MasterModel.fromJson({...data, 'id': doc.id});

      result[master.id] = master;
    }

    return result;
  }
}

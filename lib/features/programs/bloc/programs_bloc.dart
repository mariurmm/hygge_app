import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_category.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';

part 'programs_event.dart';
part 'programs_state.dart';

class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  final ProgramsRepository _repository;
  final FirebaseFirestore _firestore;

  ProgramsBloc({ProgramsRepository? repository, FirebaseFirestore? firestore})
    : _repository = repository ?? ProgramsRepositoryImpl(),
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ProgramsState()) {
    on<ProgramsInitialized>(_onInitialized);
    on<ProgramsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onInitialized(
    ProgramsInitialized event,
    Emitter<ProgramsState> emit,
  ) async {
    try {
      final programs = await _repository.fetchPrograms();
      debugPrint('PROGRAMS COUNT: ${programs.length}');
      debugPrint(
        'PROGRAMS: ${programs.map((e) => '${e.uuid} / ${e.title} / ${e.category}').toList()}',
      );
      final nearestLessonsByProgramId = await _fetchNearestLessons(programs);
      final mastersById = await _fetchMasters(programs);

      emit(
        state.copyWith(
          allPrograms: programs,
          nearestLessonsByProgramId: nearestLessonsByProgramId,
          mastersById: mastersById,
        ),
      );
    } catch (_) {
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
          .where('programId', isEqualTo: program.uuid)
          .where('startDate', isGreaterThanOrEqualTo: now)
          .orderBy('startDate')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) continue;

      final doc = snapshot.docs.first;
      final lesson = LessonModel.fromJson({...doc.data(), 'id': doc.id});

      result[program.uuid] = lesson;
    }

    return result;
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    List<ProgramModel> programs,
  ) async {
    final masterIds = programs
        .map((program) => program.masterId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, MasterModel>{};

    for (final masterId in masterIds) {
      final doc = await _firestore.collection('masters').doc(masterId).get();
      final data = doc.data();

      if (!doc.exists || data == null) continue;

      final master = MasterModel.fromJson({...data, 'id': doc.id});

      result[master.uuid] = master;
    }

    return result;
  }
}

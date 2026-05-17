import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_category.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';

part 'programs_event.dart';
part 'programs_state.dart';

class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  ProgramsBloc({
    required ProgramsRepository repository,
    FirebaseFirestore? firestore,
  }) : _repository = repository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const ProgramsState()) {
    on<ProgramsInitialized>(_onInitialized);
    on<ProgramsRefreshRequested>(_onRefreshRequested);
    on<ProgramsLocaleChanged>(_onLocaleChanged);
    on<ProgramsFilterChanged>(_onFilterChanged);
  }

  final ProgramsRepository _repository;
  final FirebaseFirestore _firestore;

  Future<void> _onInitialized(
    ProgramsInitialized event,
    Emitter<ProgramsState> emit,
  ) async {
    await _load(
      emit,
      locale: event.locale ?? state.locale,
    );
  }

  Future<void> _onRefreshRequested(
    ProgramsRefreshRequested event,
    Emitter<ProgramsState> emit,
  ) async {
    await _load(
      emit,
      locale: state.locale,
    );
  }

  Future<void> _onLocaleChanged(
    ProgramsLocaleChanged event,
    Emitter<ProgramsState> emit,
  ) async {
    final locale = _normalizeLocale(event.locale);

    if (locale == state.locale) return;

    emit(state.copyWith(locale: locale));

    await _load(
      emit,
      locale: locale,
    );
  }

  Future<void> _load(
    Emitter<ProgramsState> emit, {
    required String locale,
  }) async {
    final normalizedLocale = _normalizeLocale(locale);

    try {
      final programs = await _repository.fetchPrograms(
        locale: normalizedLocale,
      );

      AppLogger.debug(
        'ProgramsBloc: загружено ${programs.length} программ, '
        'locale=$normalizedLocale',
      );

      final nearestLessonsByProgramId = await _fetchNearestLessons(programs);
      final mastersById = await _fetchMasters(
        programs,
        locale: normalizedLocale,
      );

      emit(
        state.copyWith(
          locale: normalizedLocale,
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
          locale: normalizedLocale,
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
      state.copyWith(
        selectedFilter: ProgramFilter.values[event.filterIndex],
      ),
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
      final lesson = LessonModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });

      result[program.id] = lesson;
    }

    return result;
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    List<ProgramModel> programs, {
    required String locale,
  }) async {
    final trainerIds = programs
        .map((program) => program.trainerId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, MasterModel>{};

    for (final trainerId in trainerIds) {
      final doc = await _firestore.collection('masters').doc(trainerId).get();
      final data = doc.data();

      if (!doc.exists || data == null) continue;

      final master = MasterModel.fromJson(
        {
          ...data,
          'id': doc.id,
        },
        locale: locale,
      );

      result[master.id] = master;
    }

    return result;
  }

  String _normalizeLocale(String locale) {
    return switch (locale) {
      'en' => 'en',
      'kk' => 'kk',
      _ => LocalizedValue.defaultLocale,
    };
  }
}

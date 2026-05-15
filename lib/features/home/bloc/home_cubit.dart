import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required UpcomingLessonRepository upcomingRepo,
    ProgramsRepository? programsRepo,
    FirebaseFirestore? firestore,
  }) : _upcomingRepo = upcomingRepo,
       _programsRepo = programsRepo ?? getIt<ProgramsRepository>(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const HomeState()) {
    unawaited(loadUpcoming());
  }

  final UpcomingLessonRepository _upcomingRepo;
  final ProgramsRepository _programsRepo;
  final FirebaseFirestore _firestore;

  String _locale = LocalizedValue.defaultLocale;

  Future<void> changeLocale(String locale) async {
    final normalizedLocale = _normalizeLocale(locale);

    if (_locale == normalizedLocale) return;

    _locale = normalizedLocale;
    await loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    emit(state.copyWith(isLoading: true));

    try {
      final now = DateTime.now();
      final allLessons = await _upcomingRepo.fetchBookings(status: 'booked');

      final seenProgramIds = <String>{};

      final lessons = allLessons
          .where((lesson) {
            if (lesson.programId.isEmpty) return false;
            if (lesson.startDate.isBefore(now)) return false;

            return seenProgramIds.add(lesson.programId);
          })
          .toList(growable: false);

      final programsById = <String, ProgramModel>{};

      for (final id in seenProgramIds) {
        final program = await _programsRepo.fetchProgramById(
          id,
          locale: _locale,
        );

        if (program != null) {
          programsById[id] = program;
        }
      }

      final mastersById = await _fetchMasters(
        programsById.values,
        locale: _locale,
      );

      emit(
        state.copyWith(
          lessons: lessons,
          programsById: programsById,
          mastersById: mastersById,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    Iterable<ProgramModel> programs, {
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

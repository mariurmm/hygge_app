import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> loadUpcoming() async {
    emit(state.copyWith(isLoading: true));
    try {
      final allLessons = await _upcomingRepo.fetchBookings(status: 'booked');

      // Keep one lesson per program (earliest date wins) to avoid duplicates.
      final seenProgramIds = <String>{};
      final lessons = allLessons.where((l) {
        if (l.programId.isEmpty) return false;
        return seenProgramIds.add(l.programId);
      }).toList();

      final programIds = seenProgramIds;

      final programsById = <String, ProgramModel>{};
      for (final id in programIds) {
        final program = await _programsRepo.fetchProgramById(id);
        if (program != null) programsById[id] = program;
      }

      final mastersById = await _fetchMasters(programsById.values);

      emit(
        state.copyWith(
          lessons: lessons,
          programsById: programsById,
          mastersById: mastersById,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<Map<String, MasterModel>> _fetchMasters(
    Iterable<ProgramModel> programs,
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

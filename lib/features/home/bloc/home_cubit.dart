import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/di/injection.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final UpcomingLessonRepository _upcomingRepo;
  final ProgramsRepository _programsRepo;

  HomeCubit({
    required UpcomingLessonRepository upcomingRepo,
    ProgramsRepository? programsRepo,
  }) : _upcomingRepo = upcomingRepo,
       _programsRepo = programsRepo ?? getIt<ProgramsRepository>(),
       super(const HomeState()) {
    loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final lessons = await _upcomingRepo.fetchBookings(status: 'booked');

      final programIds = lessons
          .map((l) => l.programId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final programsById = <String, ProgramModel>{};
      for (final id in programIds) {
        final program = await _programsRepo.fetchProgramById(id);
        if (program != null) programsById[id] = program;
      }

      emit(
        state.copyWith(
          lessons: lessons,
          programsById: programsById,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

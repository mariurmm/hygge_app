import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required UpcomingLessonRepository repository, FirebaseFirestore? firestore})
    : _repository = repository,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  final UpcomingLessonRepository _repository;
  final FirebaseFirestore _firestore;

  static const String _completedStatus = 'completed';

  Future<void> _onLoadRequested(HistoryLoadRequested event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final lessons = await _repository.fetchBookings(status: _completedStatus);

      final programsById = await _fetchProgramsByLessons(lessons);
      final mastersById = await _fetchMastersByPrograms(programsById.values);

      emit(
        state.copyWith(
          status: HistoryStatus.success,
          lessons: lessons,
          programsById: programsById,
          mastersById: mastersById,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: HistoryStatus.failure));
    }
  }

  Future<Map<String, ProgramModel>> _fetchProgramsByLessons(List<LessonModel> lessons) async {
    final programIds = lessons.map((lesson) => lesson.programId).where((id) => id.isNotEmpty).toSet();

    final result = <String, ProgramModel>{};

    for (final programId in programIds) {
      final doc = await _firestore.collection('programs').doc(programId).get();

      final data = doc.data();
      if (!doc.exists || data == null) continue;

      final program = ProgramModel.fromJson({...data, 'id': doc.id});

      result[program.id] = program;
    }

    return result;
  }

  Future<Map<String, MasterModel>> _fetchMastersByPrograms(Iterable<ProgramModel> programs) async {
    final trainerIds = programs.map((program) => program.trainerId).where((id) => id.isNotEmpty).toSet();

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

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required BookingRepository repository,
    required String userId,
    FirebaseFirestore? firestore,
  }) : _repository = repository,
       _userId = userId,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  final BookingRepository _repository;
  final String _userId;
  final FirebaseFirestore _firestore;

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final bookings = await _repository.getBookingHistory(_userId);

      final lessons = <LessonModel>[];
      for (final booking in bookings) {
        final lesson = await _fetchLesson(booking.classId);
        if (lesson != null) lessons.add(lesson);
      }

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

  Future<LessonModel?> _fetchLesson(String lessonId) async {
    try {
      final doc =
          await _firestore.collection('lessons').doc(lessonId).get();
      if (!doc.exists || doc.data() == null) return null;
      return LessonModel.fromJson({...doc.data()!, 'uuid': doc.id});
    } on Exception {
      return null;
    }
  }

  Future<Map<String, ProgramModel>> _fetchProgramsByLessons(
    List<LessonModel> lessons,
  ) async {
    final programIds = lessons
        .map((lesson) => lesson.programId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, ProgramModel>{};

    for (final programId in programIds) {
      final doc =
          await _firestore.collection('programs').doc(programId).get();
      final data = doc.data();
      if (!doc.exists || data == null) continue;
      result[programId] = ProgramModel.fromJson({...data, 'id': doc.id});
    }

    return result;
  }

  Future<Map<String, MasterModel>> _fetchMastersByPrograms(
    Iterable<ProgramModel> programs,
  ) async {
    final trainerIds = programs
        .map((program) => program.trainerId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = <String, MasterModel>{};

    for (final trainerId in trainerIds) {
      final doc =
          await _firestore.collection('masters').doc(trainerId).get();
      final data = doc.data();
      if (!doc.exists || data == null) continue;
      result[trainerId] = MasterModel.fromJson({...data, 'id': doc.id});
    }

    return result;
  }
}

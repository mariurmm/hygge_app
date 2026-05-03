import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';

part 'schedule_event.dart';

final class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final UpcomingLessonRepository _repository;
  final FirebaseFirestore _firestore;

  ScheduleBloc({
    required UpcomingLessonRepository repository,
    FirebaseFirestore? firestore,
  }) : _repository = repository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(ScheduleState.initial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleRefreshRequested>(_onRefreshRequested);
    on<ScheduleDaySelected>(_onScheduleDaySelected);
  }

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    ScheduleRefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  void _onScheduleDaySelected(
    ScheduleDaySelected event,
    Emitter<ScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDay: DateTime(event.day.year, event.day.month, event.day.day),
      ),
    );
  }

  Future<void> _load(
    Emitter<ScheduleState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: ScheduleStatus.loading, clearError: true));
    }

    try {
      final results = await Future.wait<List<LessonModel>>([
        _repository.fetchBookings(status: 'booked'),
        _repository.fetchBookings(status: 'completed'),
      ]);

      final bookedLessons = results[0];
      final completedLessons = results[1];
      final allLessons = <LessonModel>[...bookedLessons, ...completedLessons];

      final programsById = await _fetchProgramsByLessons(allLessons);

      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          today: _dayOnly(DateTime.now()),
          bookedLessons: bookedLessons,
          completedLessons: completedLessons,
          programsById: programsById,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'Не удалось загрузить расписание',
        ),
      );
    }
  }

  Future<Map<String, ProgramModel>> _fetchProgramsByLessons(
    List<LessonModel> lessons,
  ) async {
    final programIds = lessons
        .map((lesson) => lesson.programId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final programsById = <String, ProgramModel>{};

    for (final programId in programIds) {
      final doc = await _firestore.collection('programs').doc(programId).get();
      final data = doc.data();

      if (!doc.exists || data == null) continue;

      final program = ProgramModel.fromJson({...data, 'id': doc.id});

      programsById[program.uuid] = program;
    }

    return programsById;
  }

  static DateTime _dayOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

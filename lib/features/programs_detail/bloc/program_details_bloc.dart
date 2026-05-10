import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_event.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_state.dart';

class ProgramDetailsBloc
    extends Bloc<ProgramDetailsEvent, ProgramDetailsState> {
  ProgramDetailsBloc({
    required FavouritesRepository favouritesRepository,
    required UpcomingLessonRepository bookingRepository,
  }) : _favouritesRepository = favouritesRepository,
       _bookingRepository = bookingRepository,
       super(ProgramDetailsState.initial()) {
    on<ProgramDetailsStarted>(_onStarted);
    on<ProgramDetailsLessonSelected>(_onLessonSelected);
    on<ProgramDetailsFavouriteToggled>(_onFavouriteToggled);
    on<ProgramDetailsBooked>(_onBooked);
  }

  final FavouritesRepository _favouritesRepository;
  final UpcomingLessonRepository _bookingRepository;

  Future<void> _onStarted(
    ProgramDetailsStarted event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProgramDetailsStatus.loading,
        program: event.program,
        lesson: event.lesson,
        master: event.master,
      ),
    );

    try {
      final favouriteIds = await _favouritesRepository.fetchFavouriteIds();
      final lessons = await _bookingRepository.fetchLessonsByProgramId(
        event.program.id,
      );
      final bookedLessons = await _bookingRepository.fetchBookings(
        status: 'booked',
      );
      final bookedLessonIds = bookedLessons.map((lesson) => lesson.id).toSet();
      final selectedLesson = _resolveSelectedLesson(
        initialLesson: event.lesson,
        lessons: lessons,
      );

      emit(
        state.copyWith(
          status: ProgramDetailsStatus.loaded,
          program: event.program,
          lesson: selectedLesson,
          master: event.master,
          availableLessons: lessons,
          bookedLessonIds: bookedLessonIds,
          isFavourite: favouriteIds.contains(event.program.id),
        ),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProgramDetailsBloc: ошибка загрузки деталей программы',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: ProgramDetailsStatus.loaded,
          program: event.program,
          lesson: event.lesson,
          master: event.master,
        ),
      );
    }
  }

  void _onLessonSelected(
    ProgramDetailsLessonSelected event,
    Emitter<ProgramDetailsState> emit,
  ) {
    emit(state.copyWith(lesson: event.lesson));
  }

  Future<void> _onFavouriteToggled(
    ProgramDetailsFavouriteToggled event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    final nextValue = !state.isFavourite;
    emit(state.copyWith(isFavourite: nextValue));

    try {
      await _favouritesRepository.setFavourite(
        programId: event.program.id,
        isFavourite: nextValue,
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProgramDetailsBloc: ошибка обновления избранного',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          isFavourite: !nextValue,
          errorMessage: 'Не удалось обновить избранное',
        ),
      );
    }
  }

  Future<void> _onBooked(
    ProgramDetailsBooked event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    if (event.lesson.isEmpty || state.bookedLessonIds.contains(event.lesson.id)) {
      return;
    }

    emit(state.copyWith(isBooking: true));

    try {
      await _bookingRepository.bookProgram(event.lesson);
      emit(
        state.copyWith(
          isBooking: false,
          bookedLessonIds: {...state.bookedLessonIds, event.lesson.id},
        ),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProgramDetailsBloc: ошибка бронирования',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          isBooking: false,
          errorMessage: 'Не удалось записаться на занятие',
        ),
      );
    }
  }

  LessonModel _resolveSelectedLesson({
    required LessonModel initialLesson,
    required List<LessonModel> lessons,
  }) {
    if (initialLesson.isNotEmpty) return initialLesson;
    if (lessons.isEmpty) return LessonModel.empty;

    final now = DateTime.now();
    for (final lesson in lessons) {
      if (lesson.startDate.isAfter(now)) return lesson;
    }
    return lessons.first;
  }
}

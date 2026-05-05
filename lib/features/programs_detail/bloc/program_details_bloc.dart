import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

import 'program_details_event.dart';
import 'program_details_state.dart';

class ProgramDetailsBloc
    extends Bloc<ProgramDetailsEvent, ProgramDetailsState> {
  final FavouritesRepository _favouritesRepository;
  final UpcomingLessonRepository _bookingRepository;

  ProgramDetailsBloc({
    required FavouritesRepository favouritesRepository,
    required UpcomingLessonRepository bookingRepository,
  }) : _favouritesRepository = favouritesRepository,
       _bookingRepository = bookingRepository,
       super(ProgramDetailsState.initial()) {
    on<ProgramDetailsStarted>(_onStarted);
    on<ProgramDetailsFavouriteToggled>(_onFavouriteToggled);
    on<ProgramDetailsBooked>(_onBooked);
  }

  Future<void> _onStarted(
    ProgramDetailsStarted event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProgramDetailsStatus.loaded,
        program: event.program,
        lesson: event.lesson,
        master: event.master,
        errorMessage: null,
      ),
    );

    try {
      final favouriteIds = await _favouritesRepository.fetchFavouriteIds();
      final isFavourite = favouriteIds.contains(event.program.id);

      emit(
        state.copyWith(
          status: ProgramDetailsStatus.loaded,
          program: event.program,
          lesson: event.lesson,
          master: event.master,
          isFavourite: isFavourite,
          errorMessage: null,
        ),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProgramDetailsBloc: ошибка загрузки избранного',
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

  Future<void> _onFavouriteToggled(
    ProgramDetailsFavouriteToggled event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    final nextValue = !state.isFavourite;

    emit(state.copyWith(isFavourite: nextValue, errorMessage: null));

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
    emit(state.copyWith(isBooking: true, errorMessage: null));

    try {
      await _bookingRepository.bookProgram(event.lesson);
      emit(state.copyWith(isBooking: false, errorMessage: null));
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
}

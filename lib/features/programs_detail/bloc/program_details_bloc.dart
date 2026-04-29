import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

import '../../shared/data/firebase_feature_repository.dart';
import 'program_details_event.dart';
import 'program_details_state.dart';

class ProgramDetailsBloc
    extends Bloc<ProgramDetailsEvent, ProgramDetailsState> {
  final FirebaseFeatureRepository repository;

  ProgramDetailsBloc({required this.repository})
    : super(ProgramDetailsState(program: LessonModel.empty)) {
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
      ),
    );

    try {
      final favouriteIds = await repository.fetchFavouriteIds();
      final isFavourite = favouriteIds.contains(event.program.uuid);

      emit(
        state.copyWith(
          status: ProgramDetailsStatus.loaded,
          program: event.program,
          isFavourite: isFavourite,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProgramDetailsStatus.loaded,
          program: event.program,
        ),
      );
    }
  }

  Future<void> _onFavouriteToggled(
    ProgramDetailsFavouriteToggled event,
    Emitter<ProgramDetailsState> emit,
  ) async {
    final nextValue = !state.isFavourite;

    emit(state.copyWith(isFavourite: nextValue));

    try {
      await repository.setFavourite(
        programId: event.program.uuid,
        isFavourite: nextValue,
      );
    } catch (_) {
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
    emit(state.copyWith(isBooking: true));

    try {
      await repository.bookProgram(event.program);

      emit(state.copyWith(isBooking: false));
    } catch (_) {
      emit(
        state.copyWith(
          isBooking: false,
          errorMessage: 'Не удалось записаться на программу',
        ),
      );
    }
  }
}

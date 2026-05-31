import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

final class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc({required ScheduleRepository scheduleRepo})
      : _scheduleRepo = scheduleRepo,
        super(ScheduleState.initial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleRefreshRequested>(_onRefresh);
    on<ScheduleDaySelected>(_onDaySelected);
    on<_UpcomingClassesUpdated>((event, emit) => emit(
          state.copyWith(
            status: ScheduleStatus.success,
            upcomingClasses: event.classes,
            clearError: true,
          ),
        ));
    on<_MonthClassesUpdated>((event, emit) => emit(
          state.copyWith(
            status: ScheduleStatus.success,
            monthClasses: event.classes,
            clearError: true,
          ),
        ));
  }

  final ScheduleRepository _scheduleRepo;
  StreamSubscription<List<ClassModel>>? _upcomingSub;

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    _subscribeUpcoming();
  }

  Future<void> _onRefresh(
    ScheduleRefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    _subscribeUpcoming();
  }

  void _onDaySelected(
    ScheduleDaySelected event,
    Emitter<ScheduleState> emit,
  ) {
    emit(state.copyWith(
      selectedDay: DateTime(
        event.day.year,
        event.day.month,
        event.day.day,
      ),
    ));
  }

  void _subscribeUpcoming() {
    _upcomingSub?.cancel();
    _upcomingSub = _scheduleRepo.watchUpcomingClasses().listen(
      (classes) {
        if (!isClosed) add(_UpcomingClassesUpdated(classes));
      },
      onError: (Object e, StackTrace st) {
        AppLogger.error(
          'ScheduleBloc: watchUpcomingClasses',
          error: e,
          stackTrace: st,
        );
        if (!isClosed) {
          emit(state.copyWith(
            status: ScheduleStatus.failure,
            error: e.toString(),
          ));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _upcomingSub?.cancel();
    return super.close();
  }
}
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';

part 'programs_state.dart';

class ProgramsBloc extends Cubit<ProgramsState> {
  final ScheduleRepository _scheduleRepo;
  StreamSubscription? _sub;

  ProgramsBloc({required ScheduleRepository scheduleRepo})
      : _scheduleRepo = scheduleRepo,
        super(const ProgramsState()) {
    _watchClasses();
  }

  void selectFilter(int index) {
    if (index < 0 || index >= ProgramsFilter.values.length) return;
    emit(state.copyWith(selectedFilter: ProgramsFilter.values[index]));
  }

  void _watchClasses() {
    _sub = _scheduleRepo.watchUpcomingClasses().listen(
      (classes) {
        final lessons = classes
            .map((cls) => LessonModel(
                  uuid: cls.id,
                  ritual: cls.type,
                  title: cls.title,
                  text: '',
                  startDate: cls.datetime,
                  finishDate: cls.datetime
                      .add(Duration(minutes: cls.durationMinutes)),
                  price: cls.price,
                  master: MasterModel.empty,
                ))
            .toList();
        emit(state.copyWith(allLessons: lessons, isLoading: false));
      },
      onError: (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

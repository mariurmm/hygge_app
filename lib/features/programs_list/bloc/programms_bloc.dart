import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';

abstract class ProgrammsState {}

class ProgrammsLoadingState extends ProgrammsState {}

class ProgrammLoadedState extends ProgrammsState {
  final List<LessonModel> lessons;
  final Set<String> favoriteIds;

  ProgrammLoadedState({required this.lessons, this.favoriteIds = const {}});

  ProgrammLoadedState copyWith({
    List<LessonModel>? lessons,
    Set<String>? favoriteIds,
  }) {
    return ProgrammLoadedState(
      lessons: lessons ?? this.lessons,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

abstract class ProgrammsEvent {}

class ProgrammsLoadEvent extends ProgrammsEvent {}

class ProgrammsBloc extends Bloc<ProgrammsEvent, ProgrammsState> {
  ProgrammsBloc() : super(ProgrammsLoadingState()) {
    on<ProgrammsLoadEvent>(_onLoad);
  }

  FutureOr<void> _onLoad(
    ProgrammsLoadEvent event,
    Emitter<ProgrammsState> emit,
  ) async {
    final now = DateTime.now();
    final response = [
      LessonModel(
        uuid: 'program-1',
        title: 'Утренняя медитация',
        text:
            'Мягкое введение в осознанность, сосредоточение на дыхании и постановке намерений.',
        startDate: now,
        finishDate: now.add(const Duration(minutes: 30)),
        price: 1000,
        master: MasterModel(
          uuid: 'master-1',
          firstName: 'Анна',
          lastName: 'Мирова',
        ),
      ),
      LessonModel(
        uuid: 'program-2',
        title: 'Утренняя медитация',
        text:
            'Мягкое введение в осознанность, сосредоточение на дыхании и постановке намерений.',
        startDate: now,
        finishDate: now.add(const Duration(minutes: 30)),
        price: 1200,
        master: MasterModel(
          uuid: 'master-2',
          firstName: 'Елена',
          lastName: 'Светлова',
        ),
      ),
    ].cast<LessonModel>();
    emit(ProgrammLoadedState(lessons: response));
  }
}

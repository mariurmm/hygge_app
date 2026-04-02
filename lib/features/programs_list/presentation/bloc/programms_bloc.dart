import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';

abstract class ProgrammsState {}

class ProgrammsLoadingState extends ProgrammsState {}

class ProgrammLoadedState extends ProgrammsState {
  final List<LessonModel> lessons;

  ProgrammLoadedState({required this.lessons});
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
    final response = [
      LessonModel(
        uuid: 'asdasdasd',
        title: 'Test',
        text: 'Description',
        startDate: DateTime.now(),
        finishDate: DateTime.now(),
        price: 1000,
        master: MasterModel(
          uuid: 'asdasd',
          firstName: 'Test',
          lastName: 'Testov',
        ),
      ),
    ].cast<LessonModel>();
    emit(ProgrammLoadedState(lessons: response));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
  }

  void _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    final lessons = List.generate(
      4,
      (index) => LessonModel(
        uuid: 'id_$index',
        title: 'Program ${index + 1}',
        text: 'Short description of the program',

        price: 0,

        master: MasterModel(
          uuid: 'master_$index',
          firstName: 'Unknown',
          lastName: '',
        ),

        startDate: DateTime.now(),
        finishDate: DateTime.now().add(const Duration(minutes: 15)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    emit(state.copyWith(lessons: lessons, isLoading: false));
  }
}

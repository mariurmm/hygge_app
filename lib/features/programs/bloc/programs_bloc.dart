import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/features/programs/bloc/programs_state.dart';

class ProgramsBloc extends Cubit<ProgramsState> {
  ProgramsBloc() : super(const ProgramsState()) {
    _loadLessons();
  }

  void selectFilter(int index) {
    if (index < 0 || index >= ProgramsFilter.values.length) return;
    emit(
      state.copyWith(
        selectedFilter: ProgramsFilter.values[index],
      ),
    );
  }

  void _loadLessons() {
    final now = DateTime.now();
    final lessons = [
      LessonModel(
        uuid: 'meditation-1',
        title: 'Утренняя медитация',
        text:
            'Мягкое введение в осознанность, сосредоточение на дыхании и постановке намерений.',
        startDate: now,
        finishDate: now.add(const Duration(minutes: 30)),
        price: 0,
        master: const MasterModel(uuid: 'm1', firstName: 'Анна', lastName: 'Ли'),
      ),
      LessonModel(
        uuid: 'yoga-1',
        title: 'Утренняя йога',
        text:
            'Согревающий поток, предназначенный для создания внутреннего тепла и снятия физического напряжения.',
        startDate: now,
        finishDate: now.add(const Duration(minutes: 90)),
        price: 0,
        master: const MasterModel(
          uuid: 'm2',
          firstName: 'Мария',
          lastName: 'Солнцева',
        ),
      ),
    ];
    emit(state.copyWith(allLessons: lessons));
  }
}

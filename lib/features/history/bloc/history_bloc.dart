import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/features/history/bloc/history_state.dart';

class HistoryBloc extends Cubit<HistoryState> {
  HistoryBloc() : super(HistoryState(lessons: _seedLessons()));

  static List<LessonModel> _seedLessons() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 5));

    LessonModel item({
      required String uuid,
      required DateTime day,
      required int hour,
      required int minute,
      required int durationMin,
      required String title,
      required String text,
    }) {
      final start = DateTime(day.year, day.month, day.day, hour, minute);
      return LessonModel(
        uuid: uuid,
        ritual: 'Вечерний ритуал',
        title: title,
        text: text,
        startDate: start,
        finishDate: start.add(Duration(minutes: durationMin)),
        price: 0,
        master: MasterModel.empty,
      );
    }

    return [
      item(
        uuid: 'hist-1',
        day: yesterday,
        hour: 8,
        minute: 0,
        durationMin: 90,
        title: 'Йога глубокого дыхания',
        text:
            'Согревающий поток, предназначенный для создания внутреннего тепла и снятия физического напряжения.',
      ),
      item(
        uuid: 'hist-2',
        day: weekAgo,
        hour: 19,
        minute: 30,
        durationMin: 45,
        title: 'Утренняя медитация',
        text:
            'Мягкое введение в осознанность, сосредоточение на дыхании и постановке намерений.',
      ),
    ];
  }
}

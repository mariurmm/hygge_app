import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:hygge_app/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:hygge_app/data/models/schedule_lesson_model.dart';

class ScheduleBloc extends Cubit<ScheduleState> {
  ScheduleBloc()
      : super(
          ScheduleState(
            visibleMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
            today: DateTime.now(),
            signedLessons: _seedLessons(DateTime.now()),
            completedSessions: 12,
            totalSessions: 15,
          ),
        );

  void nextMonth() {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month + 1, 1)));
  }

  void previousMonth() {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month - 1, 1)));
  }

  String monthLabel(DateTime month) => DateFormat('LLLL yyyy', 'ru').format(month);

  List<DateTime?> calendarCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  String lessonTimeRange(ScheduleLessonModel lesson) {
    final f = DateFormat('H:mm', 'ru');
    return '${f.format(lesson.start)} - ${f.format(lesson.end)}';
  }

  String lessonDayLabel(ScheduleLessonModel lesson) {
    final t = DateTime(state.today.year, state.today.month, state.today.day);
    final d = DateTime(lesson.day.year, lesson.day.month, lesson.day.day);
    if (d == t) return 'Сегодня';
    if (d == t.add(const Duration(days: 1))) return 'Завтра';
    return DateFormat('d MMM', 'ru').format(d);
  }

  static List<ScheduleLessonModel> _seedLessons(DateTime now) {
    final tomorrow = now.add(const Duration(days: 1));
    final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
    final end = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30);
    return [
      ScheduleLessonModel(
        ritual: 'Утренний ритуал',
        title: 'Йога глубокого дыхания',
        description:
            'Согревающий поток, предназначенный для создания внутреннего тепла и снятия физического напряжения.',
        start: start,
        end: end,
        day: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    ];
  }
}

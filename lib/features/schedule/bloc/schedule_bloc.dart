import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:hygge_app/features/schedule/bloc/schedule_state.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class ScheduleBloc extends Cubit<ScheduleState> {
  ScheduleBloc({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(
          ScheduleState(
            visibleMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
            today: DateTime.now(),
            signedLessons: const [],
            completedSessions: 0,
            totalSessions: 0,
          ),
        ) {
    _loadSchedule();
  }

  final FirebaseFeatureRepository _repository;

  Future<void> _loadSchedule() async {
    final signedLessons = await _repository.fetchBookings(status: 'booked');
    final completedLessons = await _repository.fetchBookings(status: 'completed');

    emit(
      state.copyWith(
        signedLessons: signedLessons,
        completedSessions: completedLessons.length,
        totalSessions: signedLessons.length + completedLessons.length,
      ),
    );
  }

  void nextMonth() {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month + 1, 1)));
  }

  void previousMonth() {
    final d = state.visibleMonth;
    emit(state.copyWith(visibleMonth: DateTime(d.year, d.month - 1, 1)));
  }

  String monthLabel(DateTime month, [String locale = 'en']) =>
      DateFormat('LLLL yyyy', locale).format(month);

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
}

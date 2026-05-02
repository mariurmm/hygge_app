import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart' show Equatable;
import 'package:intl/intl.dart';

import '../../../data/models/class_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/schedule_repository.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _scheduleRepo;
  final BookingRepository _bookingRepo;
  final String userId;

  StreamSubscription<List<ClassModel>>? _classesSub;
  StreamSubscription<List<ClassModel>>? _monthSub;

  ScheduleCubit({
    required ScheduleRepository scheduleRepo,
    required BookingRepository bookingRepo,
    required this.userId,
  })  : _scheduleRepo = scheduleRepo,
        _bookingRepo = bookingRepo,
        super(ScheduleState(
          visibleMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
          today: DateTime.now(),
        )) {
    _subscribeUpcoming();
    _subscribeMonth(state.visibleMonth);
  }

  void _subscribeUpcoming() {
    _classesSub?.cancel();
    _classesSub = _scheduleRepo.watchUpcomingClasses().listen(
      (classes) => emit(state.copyWith(upcomingClasses: classes)),
      onError: (e) => emit(state.copyWith(error: e.toString())),
    );
  }

  void _subscribeMonth(DateTime month) {
    _monthSub?.cancel();
    _monthSub = _scheduleRepo.watchClassesForMonth(month).listen(
      (classes) => emit(state.copyWith(monthClasses: classes)),
      onError: (e) => emit(state.copyWith(error: e.toString())),
    );
  }

  void nextMonth() {
    final d = state.visibleMonth;
    final next = DateTime(d.year, d.month + 1, 1);
    emit(state.copyWith(visibleMonth: next));
    _subscribeMonth(next);
  }

  void previousMonth() {
    final d = state.visibleMonth;
    final prev = DateTime(d.year, d.month - 1, 1);
    emit(state.copyWith(visibleMonth: prev));
    _subscribeMonth(prev);
  }

  String monthLabel(DateTime month, [String locale = 'ru']) =>
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

  BookingRepository get bookingRepo => _bookingRepo;

  @override
  Future<void> close() {
    _classesSub?.cancel();
    _monthSub?.cancel();
    return super.close();
  }
}

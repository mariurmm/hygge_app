import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  final BookingRepository _bookingRepo;
  final ScheduleRepository _scheduleRepo;

  ProfileBloc({
    required BookingRepository bookingRepo,
    required ScheduleRepository scheduleRepo,
    UserModel? user,
  })  : _bookingRepo = bookingRepo,
        _scheduleRepo = scheduleRepo,
        super(_initialState(user)) {
    _loadHistory(user?.uid ?? '');
  }

  static ProfileState _initialState(UserModel? user) {
    final name = user != null && user.isNotEmpty && user.displayName.isNotEmpty
        ? user.displayName
        : 'Жанна Цой';

    return ProfileState(
      isPremium: _hasActiveSubscription(user),
      displayName: name,
      travelProgressPercent: 0,
      sessionsCompletedThisMonth: 0,
      sessionsLeftToNextStage: 0,
      goalSessionsTotal: 15,
      isHistoryLoading: true,
    );
  }

  void syncUser(UserModel user) {
    emit(state.copyWith(
      displayName: user.isNotEmpty && user.displayName.isNotEmpty
          ? user.displayName
          : state.displayName,
      isPremium: _hasActiveSubscription(user),
    ));
    _loadHistory(user.uid);
  }

  Future<void> _loadHistory(String userId) async {
    if (userId.isEmpty) {
      emit(state.copyWith(isHistoryLoading: false));
      return;
    }
    try {
      final bookings = await _bookingRepo.getBookingHistory(userId);
      final now = DateTime.now();
      final thisMonthBookings = bookings.where((b) =>
          b.datetime.year == now.year && b.datetime.month == now.month);
      final completedThisMonth = thisMonthBookings.length;

      LessonModel? recent;
      if (bookings.isNotEmpty) {
        final cls = await _scheduleRepo.getClass(bookings.first.classId);
        if (cls != null) {
          recent = LessonModel(
            uuid: cls.id,
            ritual: cls.type,
            title: cls.title,
            text: '',
            startDate: cls.datetime,
            finishDate: cls.datetime.add(Duration(minutes: cls.durationMinutes)),
            price: cls.price,
            master: MasterModel.empty,
          );
        }
      }

      const goal = 15;
      final left = (goal - completedThisMonth).clamp(0, goal);
      final percent =
          ((completedThisMonth / goal) * 100).clamp(0, 100).toInt();

      emit(state.copyWith(
        sessionsCompletedThisMonth: completedThisMonth,
        sessionsLeftToNextStage: left,
        goalSessionsTotal: goal,
        travelProgressPercent: percent,
        recentSessionLesson: recent,
        isHistoryLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isHistoryLoading: false));
    }
  }

  static bool _hasActiveSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;
    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.endDate.isAfter(DateTime.now());
  }
}

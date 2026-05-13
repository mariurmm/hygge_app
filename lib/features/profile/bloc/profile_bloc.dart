import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/constants/app_defaults.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc({
    required BookingRepository bookingRepository,
    required ScheduleRepository scheduleRepository,
    ProgramsRepository? programsRepo,
    UserModel? user,
  }) : _bookingRepo = bookingRepository,
       _scheduleRepo = scheduleRepository,
       _programsRepo = programsRepo ?? getIt<ProgramsRepository>(),
       super(_initialState(user)) {
    _uid = user?.uid ?? '';
    unawaited(_loadHistory(_uid));
  }

  static const int _goal = 15;

  String _uid = '';
  final BookingRepository _bookingRepo;
  final ScheduleRepository _scheduleRepo;
  final ProgramsRepository _programsRepo;

  static ProfileState _initialState(UserModel? user) {
    final name = user != null && user.isNotEmpty && user.displayName.isNotEmpty
        ? user.displayName
        : kDefaultUserName;

    return ProfileState(
      isPremium: _hasActiveSubscription(user),
      displayName: name,
      sessionsLeftToNextStage: 0,
      isHistoryLoading: true,
    );
  }

  void syncUser(UserModel user) {
    _uid = user.uid;
    emit(
      state.copyWith(
        displayName: user.isNotEmpty && user.displayName.isNotEmpty
            ? user.displayName
            : state.displayName,
        isPremium: _hasActiveSubscription(user),
      ),
    );
    unawaited(_loadHistory(_uid));
  }

  Future<void> refresh() => _loadHistory(_uid);

  Future<void> _loadHistory(String userId) async {
    if (userId.isEmpty) {
      emit(state.copyWith(isHistoryLoading: false));
      return;
    }
    try {
      final bookings = await _bookingRepo.getBookingHistory(userId);
      final now = DateTime.now();

      final completedThisMonth = bookings
          .where(
            (b) => b.datetime.year == now.year && b.datetime.month == now.month,
          )
          .length;

      LessonModel? recentLesson;
      if (bookings.isNotEmpty) {
        final cls = await _scheduleRepo.getClass(bookings.first.classId);
        if (cls != null) recentLesson = _classToLesson(cls);
      }

      final left = (_goal - completedThisMonth).clamp(0, _goal);
      final percent = (completedThisMonth / _goal * 100).clamp(0, 100).toInt();

      final program = recentLesson != null && recentLesson.programId.isNotEmpty
          ? await _programsRepo.fetchProgramById(recentLesson.programId)
          : null;

      emit(
        state.copyWith(
          sessionsCompletedThisMonth: completedThisMonth,
          sessionsLeftToNextStage: left,
          goalSessionsTotal: _goal,
          travelProgressPercent: percent,
          recentSessionLesson: recentLesson,
          recentSessionProgram: program,
          isHistoryLoading: false,
        ),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'ProfileBloc: ошибка загрузки истории',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(isHistoryLoading: false, status: ProfileStatus.failure),
      );
    }
  }

  static LessonModel _classToLesson(ClassModel cls) => LessonModel(
    id: cls.id,
    programId: '',
    trainerId: cls.trainerId,
    startDate: cls.startDate,
    endDate: cls.startDate.add(Duration(minutes: cls.durationMinutes)),
  );

  static bool _hasActiveSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;
    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.endDate.isAfter(DateTime.now());
  }
}

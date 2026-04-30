import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UpcomingLessonRepository repository,
    UserModel? user,
  })  : _repository = repository,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUserSynced>(_onUserSynced);
  }

  final UpcomingLessonRepository _repository;

  static const int _goalSessionsTotal = 15;
  static const String _completedStatus = 'completed';
  static const String _fallbackName = 'Жанна Цой';

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(_applyUser(event.user, state).copyWith(status: ProfileStatus.loading));

    try {
      final completed =
          await _repository.fetchBookings(status: _completedStatus);

      final count = completed.length;
      final progress = _goalSessionsTotal == 0
          ? 0
          : ((count / _goalSessionsTotal) * 100).round().clamp(0, 100);

      emit(state.copyWith(
        status: ProfileStatus.success,
        sessionsCompletedThisMonth: count,
        goalSessionsTotal: _goalSessionsTotal,
        sessionsLeftToNextStage:
            (_goalSessionsTotal - count).clamp(0, _goalSessionsTotal),
        travelProgressPercent: progress,
        recentSessionLesson: completed.isNotEmpty ? completed.last : null,
      ));
    } on Exception {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }

  void _onUserSynced(
    ProfileUserSynced event,
    Emitter<ProfileState> emit,
  ) {
    emit(_applyUser(event.user, state));
    add(const ProfileLoadRequested());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ProfileState _applyUser(UserModel? user, ProfileState current) =>
      current.copyWith(
        displayName: _resolveName(user),
        isPremium: _hasActiveSubscription(user),
      );

  String _resolveName(UserModel? user) {
    if (user == null || user.isEmpty) return _fallbackName;
    return user.displayName.isNotEmpty ? user.displayName : _fallbackName;
  }

  bool _hasActiveSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;
    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.finishDate.isAfter(DateTime.now());
  }
}
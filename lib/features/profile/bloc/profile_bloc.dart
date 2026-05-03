import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/constants/app_defaults.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository_impl.dart';
import 'package:hygge_app/domain/use_cases/calculate_progress_use_case.dart';
import 'package:hygge_app/domain/use_cases/load_history_use_case.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  final LoadHistoryUseCase _loadHistoryUseCase;
  final CalculateProgressUseCase _calculateProgressUseCase;
  final ProgramsRepositoryImpl _programsRepo;

  ProfileBloc({
    required LoadHistoryUseCase loadHistory,
    required CalculateProgressUseCase calculateProgress,
    ProgramsRepositoryImpl? programsRepo,
    UserModel? user,
  }) : _loadHistoryUseCase = loadHistory,
       _calculateProgressUseCase = calculateProgress,
       _programsRepo = programsRepo ?? ProgramsRepositoryImpl(),
       super(_initialState(user)) {
    _loadHistory(user?.uid ?? '');
  }

  static ProfileState _initialState(UserModel? user) {
    final name = user != null && user.isNotEmpty && user.displayName.isNotEmpty ? user.displayName : kDefaultUserName;

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
    emit(
      state.copyWith(
        displayName: user.isNotEmpty && user.displayName.isNotEmpty ? user.displayName : state.displayName,
        isPremium: _hasActiveSubscription(user),
      ),
    );
    _loadHistory(user.uid);
  }

  Future<void> _loadHistory(String userId) async {
    if (userId.isEmpty) {
      emit(state.copyWith(isHistoryLoading: false));
      return;
    }
    try {
      final history = await _loadHistoryUseCase(userId);
      final progress = _calculateProgressUseCase(history.completedThisMonth);

      final lesson = history.recentLesson;
      final program = lesson != null && lesson.programId.isNotEmpty
          ? await _programsRepo.fetchProgramById(lesson.programId)
          : null;

      emit(
        state.copyWith(
          sessionsCompletedThisMonth: progress.completedThisMonth,
          sessionsLeftToNextStage: progress.sessionsLeftToNextStage,
          goalSessionsTotal: progress.goalSessionsTotal,
          travelProgressPercent: progress.travelProgressPercent,
          recentSessionLesson: lesson,
          recentSessionProgram: program,
          isHistoryLoading: false,
        ),
      );
    } catch (e, st) {
      AppLogger.error('History load failed', error: e, stackTrace: st);
      emit(state.copyWith(isHistoryLoading: false, status: ProfileStatus.failure));
    }
  }

  static bool _hasActiveSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;

    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.endDate.isAfter(DateTime.now());
  }
}

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UpcomingLessonRepository repository,
    FirebaseFirestore? firestore,
    UserModel? user,
  }) : _repository = repository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(_initialState(user)) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUserSynced>(_onUserSynced);
  }

  final UpcomingLessonRepository _repository;
  final FirebaseFirestore _firestore;

  static const int _goalSessionsTotal = 15;
  static const String _completedStatus = 'completed';
  static const String _fallbackName = 'Пользователь';

  static ProfileState _initialState(UserModel? user) {
    return ProfileState(
      displayName: _resolveName(user),
      isPremium: _hasActiveSubscription(user),
    );
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final completed = await _repository.fetchBookings(
        status: _completedStatus,
      );

      final count = completed.length;
      final progress = _goalSessionsTotal == 0
          ? 0
          : ((count / _goalSessionsTotal) * 100).round().clamp(0, 100);

      final recentLesson = completed.isNotEmpty ? completed.last : null;
      final recentProgram = recentLesson == null
          ? null
          : await _fetchProgramById(recentLesson.programId);

      final recentMaster = recentProgram == null
          ? null
          : await _fetchMasterById(
              recentLesson?.masterId.isNotEmpty == true
                  ? recentLesson!.masterId
                  : recentProgram.masterId,
            );

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          sessionsCompletedThisMonth: count,
          goalSessionsTotal: _goalSessionsTotal,
          sessionsLeftToNextStage: (_goalSessionsTotal - count).clamp(
            0,
            _goalSessionsTotal,
          ),
          travelProgressPercent: progress,
          recentSessionLesson: recentLesson,
          recentSessionProgram: recentProgram,
          recentSessionMaster: recentMaster,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }

  void _onUserSynced(ProfileUserSynced event, Emitter<ProfileState> emit) {
    emit(
      state.copyWith(
        displayName: _resolveName(event.user),
        isPremium: _hasActiveSubscription(event.user),
      ),
    );

    add(const ProfileLoadRequested());
  }

  Future<ProgramModel?> _fetchProgramById(String programId) async {
    if (programId.isEmpty) return null;

    final doc = await _firestore.collection('programs').doc(programId).get();
    final data = doc.data();

    if (!doc.exists || data == null) return null;

    return ProgramModel.fromJson({...data, 'id': doc.id});
  }

  Future<MasterModel?> _fetchMasterById(String masterId) async {
    if (masterId.isEmpty) return null;

    final doc = await _firestore.collection('masters').doc(masterId).get();
    final data = doc.data();

    if (!doc.exists || data == null) return null;

    return MasterModel.fromJson({...data, 'id': doc.id});
  }

  static String _resolveName(UserModel? user) {
    if (user == null || user.isEmpty) return _fallbackName;

    return user.displayName.trim().isNotEmpty
        ? user.displayName.trim()
        : _fallbackName;
  }

  static bool _hasActiveSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;

    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;

    return sub.finishDate.isAfter(DateTime.now());
  }
}

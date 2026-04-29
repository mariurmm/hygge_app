import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc({
    UserModel? user,
    FirebaseFeatureRepository? repository,
  })  : _repository = repository ?? FirebaseFeatureRepository(),
        super(_initialState(user)) {
    _loadProfileStats();
  }

  final FirebaseFeatureRepository _repository;

  static LessonModel _emptyRecentSessionLesson() {
    return LessonModel(
      uuid: '',
      ritual: '',
      title: '',
      text: '',
      startDate: DateTime.fromMillisecondsSinceEpoch(0),
      finishDate: DateTime.fromMillisecondsSinceEpoch(0),
      price: 0,
      master: MasterModel.empty,
    );
  }

  static ProfileState _initialState(UserModel? user) {
    final name = user != null && user.isNotEmpty && user.displayName.isNotEmpty
        ? user.displayName
        : 'Жанна Цой';
    final premium = _hasActiveFitnessSubscription(user);

    return ProfileState(
      isPremium: premium,
      displayName: name,
      travelProgressPercent: 0,
      sessionsCompletedThisMonth: 0,
      sessionsLeftToNextStage: 15,
      goalSessionsTotal: 15,
      recentSessionLesson: _emptyRecentSessionLesson(),
    );
  }

  Future<void> _loadProfileStats() async {
    final completed = await _repository.fetchBookings(status: 'completed');
    final recent = completed.isNotEmpty ? completed.last : _emptyRecentSessionLesson();
    const goal = 15;
    final completedCount = completed.length;

    emit(
      state.copyWith(
        sessionsCompletedThisMonth: completedCount,
        goalSessionsTotal: goal,
        sessionsLeftToNextStage: (goal - completedCount).clamp(0, goal),
        travelProgressPercent: goal == 0 ? 0 : ((completedCount / goal) * 100).round().clamp(0, 100),
        recentSessionLesson: recent,
      ),
    );
  }

  void syncUser(UserModel user) {
    emit(_initialState(user));
    _loadProfileStats();
  }

  static bool _hasActiveFitnessSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;
    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.finishDate.isAfter(DateTime.now());
  }
}

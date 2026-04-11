import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc({UserModel? user}) : super(_initialState(user));

  static LessonModel _recentSessionLesson() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 0);
    final end = start.add(const Duration(minutes: 90));
    return LessonModel(
      uuid: 'profile-recent-1',
      ritual: 'Утренний ритуал',
      title: 'Йога глубокого дыхания',
      text:
          'Согревающий поток, предназначенный для создания внутреннего тепла и снятия физического напряжения.',
      startDate: start,
      finishDate: end,
      price: 0,
      master: MasterModel.empty,
    );
  }

  static ProfileState _initialState(UserModel? user) {
    final name = user != null &&
            user.isNotEmpty &&
            user.displayName.isNotEmpty
        ? user.displayName
        : 'Жанна Цой';
    final premium = _hasActiveFitnessSubscription(user);

    return ProfileState(
      isPremium: premium,
      displayName: name,
      travelProgressPercent: 75,
      sessionsCompletedThisMonth: 12,
      sessionsLeftToNextStage: 4,
      goalSessionsTotal: 15,
      recentSessionLesson: _recentSessionLesson(),
    );
  }

  void syncUser(UserModel user) {
    emit(_initialState(user));
  }

  static bool _hasActiveFitnessSubscription(UserModel? user) {
    if (user == null || user.isEmpty) return false;
    final sub = user.subscription;
    if (sub == null || sub.isEmpty) return false;
    return sub.finishDate.isAfter(DateTime.now());
  }
}

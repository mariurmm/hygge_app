import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc({UserModel? user})
      : super(_initialState(user));

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
      recentSessionTimingLabel: 'Вчера 8:00',
      recentSessionImagePath: AssetPaths.homeBackground,
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

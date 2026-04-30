part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({this.user});
  final UserModel? user;
}

final class ProfileUserSynced extends ProfileEvent {
  const ProfileUserSynced(this.user);
  final UserModel user;
}
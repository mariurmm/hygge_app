part of 'profile_bloc.dart';

const int _goalSessionsTotal = 15;

enum ProfileStatus { initial, loading, success, failure }

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.isPremium = false,
    this.displayName = '',
    this.travelProgressPercent = 0,
    this.sessionsCompletedThisMonth = 0,
    this.sessionsLeftToNextStage = _goalSessionsTotal,
    this.goalSessionsTotal = _goalSessionsTotal,
    this.recentSessionLesson,
  });

  final ProfileStatus status;
  final bool isPremium;
  final String displayName;
  final int travelProgressPercent;
  final int sessionsCompletedThisMonth;
  final int sessionsLeftToNextStage;
  final int goalSessionsTotal;
  final LessonModel? recentSessionLesson;

  bool get isLoading => status == ProfileStatus.loading;

  ProfileState copyWith({
    ProfileStatus? status,
    bool? isPremium,
    String? displayName,
    int? travelProgressPercent,
    int? sessionsCompletedThisMonth,
    int? sessionsLeftToNextStage,
    int? goalSessionsTotal,
    LessonModel? recentSessionLesson,
  }) =>
      ProfileState(
        status: status ?? this.status,
        isPremium: isPremium ?? this.isPremium,
        displayName: displayName ?? this.displayName,
        travelProgressPercent:
            travelProgressPercent ?? this.travelProgressPercent,
        sessionsCompletedThisMonth:
            sessionsCompletedThisMonth ?? this.sessionsCompletedThisMonth,
        sessionsLeftToNextStage:
            sessionsLeftToNextStage ?? this.sessionsLeftToNextStage,
        goalSessionsTotal: goalSessionsTotal ?? this.goalSessionsTotal,
        recentSessionLesson: recentSessionLesson ?? this.recentSessionLesson,
      );

  @override
  List<Object?> get props => [
        status,
        isPremium,
        displayName,
        travelProgressPercent,
        sessionsCompletedThisMonth,
        sessionsLeftToNextStage,
        goalSessionsTotal,
        recentSessionLesson,
      ];
}
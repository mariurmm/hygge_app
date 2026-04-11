import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isPremium;
  final String displayName;
  final int travelProgressPercent;
  final int sessionsCompletedThisMonth;
  final int sessionsLeftToNextStage;
  final int goalSessionsTotal;
  final String recentSessionTimingLabel;
  final String recentSessionImagePath;

  const ProfileState({
    required this.isPremium,
    required this.displayName,
    required this.travelProgressPercent,
    required this.sessionsCompletedThisMonth,
    required this.sessionsLeftToNextStage,
    required this.goalSessionsTotal,
    required this.recentSessionTimingLabel,
    required this.recentSessionImagePath,
  });

  String get statusLine =>
      isPremium ? 'Член премиум-клуба' : 'Стандартный аккаунт';

  String get monthlyTravelDescription =>
      '$sessionsCompletedThisMonth сеансов завершены в этом месяце';

  String get leftSessionsLine =>
      '$sessionsLeftToNextStage сессии до следующего этапа';

  String get goalLine => 'Цель: $goalSessionsTotal сеансов';

  ProfileState copyWith({
    bool? isPremium,
    String? displayName,
    int? travelProgressPercent,
    int? sessionsCompletedThisMonth,
    int? sessionsLeftToNextStage,
    int? goalSessionsTotal,
    String? recentSessionTimingLabel,
    String? recentSessionImagePath,
  }) {
    return ProfileState(
      isPremium: isPremium ?? this.isPremium,
      displayName: displayName ?? this.displayName,
      travelProgressPercent:
          travelProgressPercent ?? this.travelProgressPercent,
      sessionsCompletedThisMonth:
          sessionsCompletedThisMonth ?? this.sessionsCompletedThisMonth,
      sessionsLeftToNextStage:
          sessionsLeftToNextStage ?? this.sessionsLeftToNextStage,
      goalSessionsTotal: goalSessionsTotal ?? this.goalSessionsTotal,
      recentSessionTimingLabel:
          recentSessionTimingLabel ?? this.recentSessionTimingLabel,
      recentSessionImagePath:
          recentSessionImagePath ?? this.recentSessionImagePath,
    );
  }

  @override
  List<Object?> get props => [
        isPremium,
        displayName,
        travelProgressPercent,
        sessionsCompletedThisMonth,
        sessionsLeftToNextStage,
        goalSessionsTotal,
        recentSessionTimingLabel,
        recentSessionImagePath,
      ];
}

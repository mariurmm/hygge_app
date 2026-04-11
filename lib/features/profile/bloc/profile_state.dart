import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

class ProfileState extends Equatable {
  final bool isPremium;
  final String displayName;
  final int travelProgressPercent;
  final int sessionsCompletedThisMonth;
  final int sessionsLeftToNextStage;
  final int goalSessionsTotal;
  final LessonModel recentSessionLesson;

  const ProfileState({
    required this.isPremium,
    required this.displayName,
    required this.travelProgressPercent,
    required this.sessionsCompletedThisMonth,
    required this.sessionsLeftToNextStage,
    required this.goalSessionsTotal,
    required this.recentSessionLesson,
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
    LessonModel? recentSessionLesson,
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
      recentSessionLesson:
          recentSessionLesson ?? this.recentSessionLesson,
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
        recentSessionLesson,
      ];
}

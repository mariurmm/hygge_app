import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

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
    this.recentSessionProgram,
    this.recentSessionMaster,
    this.isHistoryLoading = false,
  });

  final ProfileStatus status;
  final bool isPremium;
  final String displayName;
  final int travelProgressPercent;
  final int sessionsCompletedThisMonth;
  final int sessionsLeftToNextStage;
  final int goalSessionsTotal;
  final LessonModel? recentSessionLesson;
  final ProgramModel? recentSessionProgram;
  final MasterModel? recentSessionMaster;
  final bool isHistoryLoading;

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
    ProgramModel? recentSessionProgram,
    MasterModel? recentSessionMaster,
    bool? isHistoryLoading,
  }) => ProfileState(
    status: status ?? this.status,
    isPremium: isPremium ?? this.isPremium,
    displayName: displayName ?? this.displayName,
    travelProgressPercent: travelProgressPercent ?? this.travelProgressPercent,
    sessionsCompletedThisMonth: sessionsCompletedThisMonth ?? this.sessionsCompletedThisMonth,
    sessionsLeftToNextStage: sessionsLeftToNextStage ?? this.sessionsLeftToNextStage,
    goalSessionsTotal: goalSessionsTotal ?? this.goalSessionsTotal,
    recentSessionLesson: recentSessionLesson ?? this.recentSessionLesson,
    recentSessionProgram: recentSessionProgram ?? this.recentSessionProgram,
    recentSessionMaster: recentSessionMaster ?? this.recentSessionMaster,
    isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
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
    recentSessionProgram,
    recentSessionMaster,
    isHistoryLoading,
  ];
}

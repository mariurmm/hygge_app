/// Result of the monthly-progress calculation.
class ProgressResult {
  const ProgressResult({
    required this.completedThisMonth,
    required this.sessionsLeftToNextStage,
    required this.goalSessionsTotal,
    required this.travelProgressPercent,
  });

  final int completedThisMonth;
  final int sessionsLeftToNextStage;
  final int goalSessionsTotal;
  final int travelProgressPercent;
}

/// Pure computation: given how many sessions a user completed this month,
/// derives the remaining sessions and the 0-100 progress percentage.
class CalculateProgressUseCase {
  const CalculateProgressUseCase({this.goal = _defaultGoal});

  static const int _defaultGoal = 15;

  final int goal;

  ProgressResult call(int completedThisMonth) {
    final left = (goal - completedThisMonth).clamp(0, goal);
    final percent = ((completedThisMonth / goal) * 100).clamp(0, 100).toInt();
    return ProgressResult(
      completedThisMonth: completedThisMonth,
      sessionsLeftToNextStage: left,
      goalSessionsTotal: goal,
      travelProgressPercent: percent,
    );
  }
}

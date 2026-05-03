import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/domain/use_cases/calculate_progress_use_case.dart';

void main() {
  group('CalculateProgressUseCase', () {
    const useCase = CalculateProgressUseCase(); // goal = 15

    test('zero sessions → 0 % and 15 left', () {
      final r = useCase(0);
      expect(r.completedThisMonth, 0);
      expect(r.sessionsLeftToNextStage, 15);
      expect(r.goalSessionsTotal, 15);
      expect(r.travelProgressPercent, 0);
    });

    test('half goal → 50 %', () {
      final r = useCase(7); // floor(7/15*100) = 46
      expect(r.completedThisMonth, 7);
      expect(r.sessionsLeftToNextStage, 8);
      expect(r.travelProgressPercent, 46);
    });

    test('exactly at goal → 100 % and 0 left', () {
      final r = useCase(15);
      expect(r.sessionsLeftToNextStage, 0);
      expect(r.travelProgressPercent, 100);
    });

    test('over goal → clamped to 100 % and 0 left', () {
      final r = useCase(20);
      expect(r.sessionsLeftToNextStage, 0);
      expect(r.travelProgressPercent, 100);
    });

    test('custom goal is respected', () {
      const custom = CalculateProgressUseCase(goal: 10);
      final r = custom(5);
      expect(r.goalSessionsTotal, 10);
      expect(r.sessionsLeftToNextStage, 5);
      expect(r.travelProgressPercent, 50);
    });

    test('single session', () {
      final r = useCase(1);
      expect(r.completedThisMonth, 1);
      expect(r.sessionsLeftToNextStage, 14);
      expect(r.travelProgressPercent, 6); // floor(1/15*100)
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

void main() {
  final base = DateTime(2025, 6, 1, 10);

  LessonModel makeLesson({required int current, required int max}) =>
      LessonModel(
        id: 'l-1',
        programId: 'p-1',
        startDate: base,
        endDate: base.add(const Duration(hours: 1)),
        currentParticipants: current,
        maxParticipants: max,
      );

  group('LessonModel.isFull', () {
    test('isFull_isFalse_whenCurrentLessThanMax', () {
      expect(makeLesson(current: 4, max: 5).isFull, isFalse);
    });

    test('isFull_isTrue_whenCurrentEqualsMax', () {
      expect(makeLesson(current: 5, max: 5).isFull, isTrue);
    });

    test('isFull_isTrue_whenCurrentExceedsMax', () {
      expect(makeLesson(current: 6, max: 5).isFull, isTrue);
    });

    test('isFull_isFalse_whenMaxIsZero', () {
      expect(makeLesson(current: 0, max: 0).isFull, isFalse);
    });
  });

  test('fromJson_parsesCurrentAndMaxParticipants', () {
    final json = <String, dynamic>{
      'uuid': 'l-1',
      'programId': 'p-1',
      'masterId': 't-1',
      'startDate': '2025-06-01T10:00:00.000',
      'finishDate': '2025-06-01T11:00:00.000',
      'currentParticipants': 7,
      'maxParticipants': 10,
    };

    final lesson = LessonModel.fromJson(json);

    expect(lesson.currentParticipants, 7);
    expect(lesson.maxParticipants, 10);
    expect(lesson.isFull, isFalse);
  });
}

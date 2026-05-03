import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/domain/use_cases/map_class_to_lesson_use_case.dart';

// ---------------------------------------------------------------------------
// Test double — uses `implements` so no Firebase initializer is triggered.
// ---------------------------------------------------------------------------

class _FakeScheduleRepository implements ScheduleRepository {
  final ClassModel? classToReturn;

  const _FakeScheduleRepository({this.classToReturn});

  @override
  Future<ClassModel?> getClass(String classId) async => classToReturn;

  @override
  Stream<List<ClassModel>> watchUpcomingClasses() => const Stream.empty();

  @override
  Stream<List<ClassModel>> watchClassesForMonth(DateTime month) =>
      const Stream.empty();

  @override
  Future<void> incrementParticipants(String classId) async {}

  @override
  Future<void> decrementParticipants(String classId) async {}
}

// ---------------------------------------------------------------------------

void main() {
  final baseClass = ClassModel(
    id: 'cls-1',
    title: 'Morning Yoga',
    type: 'yoga',
    datetime: DateTime(2026, 5, 10, 9, 0),
    durationMinutes: 60,
    trainerId: 'trainer-1',
    maxParticipants: 10,
    currentParticipants: 3,
    price: 1500,
    isIncludedInSubscription: true,
  );

  group('MapClassToLessonUseCase.fromClass', () {
    late MapClassToLessonUseCase useCase;

    setUp(() {
      useCase = MapClassToLessonUseCase(
        scheduleRepository: const _FakeScheduleRepository(),
      );
    });

    test('maps id, title, type correctly', () {
      final lesson = useCase.fromClass(baseClass);
      expect(lesson.uuid, 'cls-1');
      expect(lesson.title, 'Morning Yoga');
      expect(lesson.ritual, 'yoga');
    });

    test('finishDate = startDate + durationMinutes', () {
      final lesson = useCase.fromClass(baseClass);
      expect(lesson.startDate, DateTime(2026, 5, 10, 9, 0));
      expect(lesson.finishDate, DateTime(2026, 5, 10, 10, 0));
    });

    test('price is preserved', () {
      final lesson = useCase.fromClass(baseClass);
      expect(lesson.price, 1500.0);
    });

    test('master defaults to MasterModel.empty', () {
      final lesson = useCase.fromClass(baseClass);
      expect(lesson.master, MasterModel.empty);
    });

    test('text is empty string', () {
      final lesson = useCase.fromClass(baseClass);
      expect(lesson.text, '');
    });

    test('zero-duration class → finishDate equals startDate', () {
      final cls = baseClass.copyWith(durationMinutes: 0);
      final lesson = useCase.fromClass(cls);
      expect(lesson.finishDate, lesson.startDate);
    });
  });

  group('MapClassToLessonUseCase.call', () {
    test('returns null when class not found in Firestore', () async {
      final useCase = MapClassToLessonUseCase(
        scheduleRepository: const _FakeScheduleRepository(classToReturn: null),
      );
      expect(await useCase('missing-id'), isNull);
    });

    test('returns LessonModel when class exists', () async {
      final useCase = MapClassToLessonUseCase(
        scheduleRepository: _FakeScheduleRepository(classToReturn: baseClass),
      );
      final lesson = await useCase('cls-1');
      expect(lesson, isA<LessonModel>());
      expect(lesson!.uuid, 'cls-1');
    });
  });
}

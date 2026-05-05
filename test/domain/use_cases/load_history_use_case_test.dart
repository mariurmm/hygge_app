import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';
import 'package:hygge_app/domain/use_cases/load_history_use_case.dart';
import 'package:hygge_app/domain/use_cases/map_class_to_lesson_use_case.dart';

// ---------------------------------------------------------------------------
// Test doubles — `implements` avoids Firebase initializers.
// ---------------------------------------------------------------------------

class _FakeBookingRepository implements BookingRepository {
  const _FakeBookingRepository(this.history);

  final List<BookingModel> history;

  @override
  Future<List<BookingModel>> getBookingHistory(String userId) async => history;

  @override
  Future<BookingModel?> getBookingForClass(
      String userId, String classId) async =>
      null;

  @override
  Future<BookingModel> createBooking(
          String userId, String classId, DateTime datetime) async =>
      BookingModel.empty;

  @override
  Future<void> updateBookingStatus(
          String userId, String bookingId, BookingStatus status) async {}

  @override
  Future<List<BookingModel>> getUpcomingBookings(String userId) async => [];

  @override
  Future<List<Map<String, dynamic>>> getPendingBookingsForNotification(
          String userId) async =>
      [];

  @override
  Stream<List<BookingModel>> watchUserBookings(String userId) =>
      const Stream.empty();
}

class _FakeScheduleRepository implements ScheduleRepository {
  @override
  Future<ClassModel?> getClass(String classId) async => null;

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

// Subclasses MapClassToLessonUseCase but overrides `call` to return a fixed
// value — avoids any Firestore access while still satisfying the type.
class _StubMapLesson extends MapClassToLessonUseCase {
  _StubMapLesson(this.stub)
      : super(scheduleRepository: _FakeScheduleRepository());

  final LessonModel? stub;

  @override
  Future<LessonModel?> call(String classId) async => stub;
}

// ---------------------------------------------------------------------------

BookingModel _booking({
  required String id,
  required DateTime datetime,
  BookingStatus status = BookingStatus.confirmed,
}) =>
    BookingModel(
      id: id,
      userId: 'user-1',
      classId: 'cls-$id',
      datetime: datetime,
      status: status,
      notificationSent: false,
    );

void main() {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month, 15);
  final lastMonth = DateTime(now.year, now.month - 1, 15);

  group('LoadHistoryUseCase', () {
    test('empty history → 0 completed, no recent lesson', () async {
      final useCase = LoadHistoryUseCase(
        bookingRepository: const _FakeBookingRepository([]),
        mapLesson: _StubMapLesson(null),
      );
      final result = await useCase('user-1');
      expect(result.completedThisMonth, 0);
      expect(result.recentLesson, isNull);
    });

    test('counts only bookings within the current calendar month', () async {
      final bookings = [
        _booking(id: '1', datetime: thisMonth),
        _booking(id: '2', datetime: thisMonth),
        _booking(id: '3', datetime: lastMonth),
      ];
      final useCase = LoadHistoryUseCase(
        bookingRepository: _FakeBookingRepository(bookings),
        mapLesson: _StubMapLesson(null),
      );
      final result = await useCase('user-1');
      expect(result.completedThisMonth, 2);
    });

    test('returns recentLesson from mapLesson for the first booking', () async {
      final lesson = LessonModel(
        id: 'cls-1',
        programId: '',
        startDate: thisMonth,
        endDate: thisMonth.add(const Duration(hours: 1)),
      );
      final useCase = LoadHistoryUseCase(
        bookingRepository: _FakeBookingRepository([
          _booking(id: '1', datetime: thisMonth),
        ]),
        mapLesson: _StubMapLesson(lesson),
      );
      final result = await useCase('user-1');
      expect(result.recentLesson, lesson);
    });

    test('recentLesson is null when mapLesson returns null', () async {
      final useCase = LoadHistoryUseCase(
        bookingRepository: _FakeBookingRepository([
          _booking(id: '1', datetime: thisMonth),
        ]),
        mapLesson: _StubMapLesson(null),
      );
      final result = await useCase('user-1');
      expect(result.completedThisMonth, 1);
      expect(result.recentLesson, isNull);
    });

    test('all bookings from last month → 0 this month', () async {
      final bookings = List.generate(
        5,
        (i) => _booking(id: '$i', datetime: lastMonth),
      );
      final useCase = LoadHistoryUseCase(
        bookingRepository: _FakeBookingRepository(bookings),
        mapLesson: _StubMapLesson(null),
      );
      final result = await useCase('user-1');
      expect(result.completedThisMonth, 0);
    });
  });
}

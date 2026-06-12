import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/core/utils/failure.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';
import 'package:hygge_app/features/booking/cubit/booking_cubit.dart';

// ---------------------------------------------------------------------------
// Test doubles
//
// BookingRepository и SubscriptionRepository — конкретные классы с миксином
// RepositoryExecutorMixin, который объявляет execute() и logError() как
// @protected. При implements Dart требует их реализовать тоже.
// Проще всего добавить заглушки прямо здесь.
// ---------------------------------------------------------------------------

class _FakeBookingRepository implements BookingRepository {
  BookingModel? bookingToReturn;
  String? lastCancelledBookingId;
  bool createCalled = false;

  // ── RepositoryExecutorMixin stubs ────────────────────────────────────────

  @override
  Future<T> execute<T>({
    required Future<T> Function() action,
    required String actionName,
  }) => action();

  @override
  void logError(String actionName, Object error, StackTrace stackTrace) {}

  // ── BookingRepository API ────────────────────────────────────────────────

  @override
  Future<BookingModel?> getBookingForClass(
    String userId,
    String classId,
  ) async => bookingToReturn;

  @override
  Future<BookingModel> createBooking(
    String userId,
    String classId,
    DateTime datetime,
  ) async {
    createCalled = true;
    return BookingModel(
      id: 'new-booking',
      userId: userId,
      classId: classId,
      datetime: datetime,
      status: BookingStatus.pending,
      notificationSent: false,
    );
  }

  @override
  Future<void> updateBookingStatus(
    String userId,
    String bookingId,
    BookingStatus status,
  ) async {
    lastCancelledBookingId = bookingId;
  }

  @override
  Stream<List<BookingModel>> watchUserBookings(String userId) =>
      const Stream.empty();

  @override
  Future<List<BookingModel>> getUpcomingBookings(String userId) async => [];

  @override
  Future<List<BookingModel>> getBookingHistory(String userId) async => [];

  @override
  Future<List<Map<String, dynamic>>> getPendingBookingsForNotification(
    String userId,
  ) async => [];

  @override
  Future<BookingModel> bookLesson(
    String userId,
    String lessonId,
    DateTime datetime,
  ) async => BookingModel(
    id: 'lesson-booking',
    userId: userId,
    classId: lessonId,
    datetime: datetime,
    status: BookingStatus.pending,
    notificationSent: false,
  );
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  SubscriptionModel? subscriptionToReturn;

  // ── RepositoryExecutorMixin stubs ────────────────────────────────────────

  @override
  Future<T> execute<T>({
    required Future<T> Function() action,
    required String actionName,
  }) => action();

  @override
  void logError(String actionName, Object error, StackTrace stackTrace) {}

  // ── SubscriptionRepository API ───────────────────────────────────────────

  @override
  Future<SubscriptionModel?> getSubscription(String userId) async =>
      subscriptionToReturn;

  @override
  Stream<SubscriptionModel?> watchSubscription(String userId) =>
      const Stream.empty();

  @override
  Future<void> deductSession(String userId) async {}

  @override
  Future<void> saveFcmToken(String userId, String token) async {}

  @override
  Future<void> createDemoSubscription(String userId) async {}
}

// ---------------------------------------------------------------------------
// Фабрика кубита для тестов
// ---------------------------------------------------------------------------

BookingCubit _makeCubit({
  _FakeBookingRepository? bookingRepo,
  _FakeSubscriptionRepository? subscriptionRepo,
  bool demoMode = false,
}) {
  return BookingCubit(
    bookingRepo: bookingRepo ?? _FakeBookingRepository(),
    subscriptionRepo: subscriptionRepo ?? _FakeSubscriptionRepository(),
    userId: 'user-1',
    demoMode: demoMode,
  );
}

// ---------------------------------------------------------------------------
// Тестовые данные
// ---------------------------------------------------------------------------

final _baseBooking = BookingModel(
  id: 'booking-42',
  userId: 'user-1',
  classId: 'class-1',
  datetime: DateTime(2025),
  status: BookingStatus.pending,
  notificationSent: false,
);

final _activeSubscription = SubscriptionModel(
  id: 'sub-1',
  userId: 'user-1',
  totalSessions: 10,
  usedSessions: 2,
  startDate: DateTime(2024),
  endDate: DateTime(2027, 12, 31),
  isActive: true,
);

final _classModel = ClassModel(
  id: 'class-1',
  title: 'Йога',
  type: 'Групповая',
  startDate: DateTime(2025, 6, 1, 10),
  durationMinutes: 60,
  trainerId: 'trainer-1',
  maxParticipants: 15,
  currentParticipants: 3,
  price: 0,
  isIncludedInSubscription: true,
);

// ---------------------------------------------------------------------------
// Тесты
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── requestCancelBooking ─────────────────────────────────────────────────

  group('BookingCubit.requestCancelBooking()', () {
    test(
      'emits cancelConfirmationRequired when existingBooking is set',
      () {
        final cubit = _makeCubit(); // объявление
        cubit
          ..emit(cubit.state.copyWith(existingBooking: _baseBooking))
          ..requestCancelBooking();

        expect(
          cubit.state.status,
          BookingCubitStatus.cancelConfirmationRequired,
        );
        expect(cubit.state.existingBooking?.id, 'booking-42');
      },
    );

    test('is a no-op when existingBooking is null', () {
      final cubit = _makeCubit();
      expect(cubit.state.existingBooking, isNull);

      cubit.requestCancelBooking();

      expect(cubit.state.status, BookingCubitStatus.idle);
    });
  });

  // ── cancelBooking ────────────────────────────────────────────────────────

  group('BookingCubit.cancelBooking()', () {
    test('emits cancelled on success', () async {
      final cubit = _makeCubit();

      await cubit.cancelBooking('booking-42');

      expect(cubit.state.status, BookingCubitStatus.cancelled);
      expect(cubit.state.message, 'Запись отменена');
    });

    test('emits error when repository throws', () async {
      final cubit = BookingCubit(
        bookingRepo: _ThrowingBookingRepository(),
        subscriptionRepo: _FakeSubscriptionRepository(),
        userId: 'user-1',
      );

      await cubit.cancelBooking('booking-42');

      expect(cubit.state.status, BookingCubitStatus.error);
    });
  });

  // ── bookClass ────────────────────────────────────────────────────────────

  group('BookingCubit.bookClass()', () {
    test('emits success in demoMode without subscription', () async {
      final cubit = _makeCubit(demoMode: true);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.success);
    });

    test('emits success with valid subscription', () async {
      final subRepo = _FakeSubscriptionRepository()
        ..subscriptionToReturn = _activeSubscription;
      final cubit = _makeCubit(subscriptionRepo: subRepo);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.success);
    });

    test('emits alreadyBooked when booking already exists', () async {
      final bookingRepo = _FakeBookingRepository()
        ..bookingToReturn = _baseBooking;
      final cubit = _makeCubit(bookingRepo: bookingRepo);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.alreadyBooked);
      expect(cubit.state.existingBooking?.id, 'booking-42');
    });

    test('emits noSubscription when subscription is missing', () async {
      final cubit = _makeCubit();

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.noSubscription);
    });

    test('emits classFull when all seats are taken', () async {
      final subRepo = _FakeSubscriptionRepository()
        ..subscriptionToReturn = _activeSubscription;
      final fullClass = _classModel.copyWith(
        maxParticipants: 15,
        currentParticipants: 15,
      );
      final cubit = _makeCubit(subscriptionRepo: subRepo);

      await cubit.bookClass(fullClass);

      expect(cubit.state.status, BookingCubitStatus.classFull);
    });

    test('classFull is checked before subscription', () async {
      final fullClass = _classModel.copyWith(
        maxParticipants: 5,
        currentParticipants: 5,
      );
      final cubit = _makeCubit();

      await cubit.bookClass(fullClass);

      expect(cubit.state.status, BookingCubitStatus.classFull);
    });

    test(
      'bookClass_emitsClassFull_whenRepositoryThrowsClassFullFailure',
      () async {
        // Non-full class so client-side isFull check passes;
        // repo simulates race-condition and throws ClassFullFailure.
        final cubit = BookingCubit(
          bookingRepo: _ThrowingClassFullBookingRepository(),
          subscriptionRepo: _FakeSubscriptionRepository(),
          userId: 'user-1',
        );

        await cubit.bookClass(_classModel);

        expect(cubit.state.status, BookingCubitStatus.classFull);
      },
    );
  });

  // ── seats logic ──────────────────────────────────────────────────────────

  group('ClassModel seats logic', () {
    test('isFull is false when seats are available', () {
      final c = _classModel.copyWith(
        maxParticipants: 15,
        currentParticipants: 14,
      );
      expect(c.isFull, isFalse);
    });

    test('isFull is true when currentParticipants == maxParticipants', () {
      final c = _classModel.copyWith(
        maxParticipants: 15,
        currentParticipants: 15,
      );
      expect(c.isFull, isTrue);
    });

    test('isFull is true when currentParticipants > maxParticipants', () {
      final c = _classModel.copyWith(
        maxParticipants: 15,
        currentParticipants: 16,
      );
      expect(c.isFull, isTrue);
    });

    test('default maxParticipants is 15', () {
      expect(_classModel.maxParticipants, 15);
    });
  });

  // ── demoMode ─────────────────────────────────────────────────────────────

  group('BookingCubit demoMode', () {
    test('succeeds without subscription when demoMode=true', () async {
      final cubit = _makeCubit(demoMode: true);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.success);
    });

    test('fails without subscription when demoMode=false', () async {
      final cubit = _makeCubit();

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.noSubscription);
    });
  });
}

// ---------------------------------------------------------------------------
// Заглушка, которая бросает исключение при updateBookingStatus.
// ---------------------------------------------------------------------------

class _ThrowingBookingRepository extends _FakeBookingRepository {
  @override
  Future<void> updateBookingStatus(
    String userId,
    String bookingId,
    BookingStatus status,
  ) async {
    throw Exception('network error');
  }
}

// ---------------------------------------------------------------------------
// Заглушка, которая бросает ClassFullFailure при createBooking
// (имитирует race-condition: место занято между client-check и транзакцией).
// ---------------------------------------------------------------------------

class _ThrowingClassFullBookingRepository extends _FakeBookingRepository {
  @override
  Future<BookingModel> createBooking(
    String userId,
    String classId,
    DateTime datetime,
  ) async {
    throw ClassFullFailure(message: 'Class $classId is full');
  }
}

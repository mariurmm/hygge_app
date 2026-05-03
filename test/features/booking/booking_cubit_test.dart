import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';
import 'package:hygge_app/features/booking/cubit/booking_cubit.dart';

// ---------------------------------------------------------------------------
// Test doubles — implement the concrete classes to avoid Firebase initializers.
// ---------------------------------------------------------------------------

class _FakeBookingRepository implements BookingRepository {
  BookingModel? bookingToReturn;
  String? lastCancelledBookingId;
  bool createCalled = false;

  @override
  Future<BookingModel?> getBookingForClass(String userId, String classId) async =>
      bookingToReturn;

  @override
  Future<BookingModel> createBooking(
      String userId, String classId, DateTime datetime) async {
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
      String userId, String bookingId, BookingStatus status) async {
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
      String userId) async => [];
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  SubscriptionModel? subscriptionToReturn;

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
}

// ---------------------------------------------------------------------------

BookingCubit _makeCubit({
  _FakeBookingRepository? bookingRepo,
  _FakeSubscriptionRepository? subscriptionRepo,
}) {
  return BookingCubit(
    bookingRepo: bookingRepo ?? _FakeBookingRepository(),
    subscriptionRepo: subscriptionRepo ?? _FakeSubscriptionRepository(),
    userId: 'user-1',
  );
}

final _baseBooking = BookingModel(
  id: 'booking-42',
  userId: 'user-1',
  classId: 'class-1',
  datetime: DateTime(2025, 1, 1),
  status: BookingStatus.pending,
  notificationSent: false,
);

final _activeSubscription = SubscriptionModel(
  id: 'sub-1',
  userId: 'user-1',
  totalSessions: 10,
  usedSessions: 2,
  startDate: DateTime(2026, 1, 1),
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
  maxParticipants: 10,
  currentParticipants: 3,
  price: 0,
  isIncludedInSubscription: true,
);

// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── requestCancelBooking ─────────────────────────────────────────────────

  group('BookingCubit.requestCancelBooking()', () {
    test('emits cancelConfirmationRequired when existingBooking is set', () {
      final cubit = _makeCubit();
      // Seed existing booking into state via checkBookingStatus path (sync).
      cubit.emit(cubit.state.copyWith(existingBooking: _baseBooking));

      cubit.requestCancelBooking();

      expect(
        cubit.state.status,
        BookingCubitStatus.cancelConfirmationRequired,
      );
      // existingBooking must be preserved so the listener can read the id.
      expect(cubit.state.existingBooking?.id, 'booking-42');
    });

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
    test('emits success when booking is created', () async {
      final subRepo = _FakeSubscriptionRepository()
        ..subscriptionToReturn = _activeSubscription;
      final cubit = _makeCubit(subscriptionRepo: subRepo);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.success);
    });

    test('emits alreadyBooked when a booking already exists', () async {
      final bookingRepo = _FakeBookingRepository()
        ..bookingToReturn = _baseBooking;
      final cubit = _makeCubit(bookingRepo: bookingRepo);

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.alreadyBooked);
    });

    test('emits noSubscription when subscription is missing', () async {
      final cubit = _makeCubit(); // subscriptionToReturn == null

      await cubit.bookClass(_classModel);

      expect(cubit.state.status, BookingCubitStatus.noSubscription);
    });

    test('emits classFull when class has no seats', () async {
      final subRepo = _FakeSubscriptionRepository()
        ..subscriptionToReturn = _activeSubscription;
      final fullClass = _classModel.copyWith(
        maxParticipants: 5,
        currentParticipants: 5,
      );
      final cubit = _makeCubit(subscriptionRepo: subRepo);

      await cubit.bookClass(fullClass);

      expect(cubit.state.status, BookingCubitStatus.classFull);
    });
  });
}

// Repository that always throws on updateBookingStatus.
class _ThrowingBookingRepository extends _FakeBookingRepository {
  @override
  Future<void> updateBookingStatus(
      String userId, String bookingId, BookingStatus status) async {
    throw Exception('network error');
  }
}

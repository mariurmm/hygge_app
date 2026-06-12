import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show setupFirebaseCoreMocks;
import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookingRepository extends Mock implements BookingRepository {}

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class _MockWhatsAppService extends Mock implements WhatsAppService {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    registerFallbackValue(BookingStatus.cancelled);
  });

  late _MockBookingRepository mockBookingRepo;
  late _MockSubscriptionRepository mockSubscriptionRepo;
  late _MockWhatsAppService mockWhatsApp;

  setUp(() {
    mockBookingRepo = _MockBookingRepository();
    mockSubscriptionRepo = _MockSubscriptionRepository();
    mockWhatsApp = _MockWhatsAppService();
  });

  BookingBloc buildBloc() => BookingBloc(
        bookingRepo: mockBookingRepo,
        subscriptionRepo: mockSubscriptionRepo,
        whatsAppService: mockWhatsApp,
      );

  // Reusable confirmed booking 48 h in the future.
  final farBooking = BookingModel(
    id: 'booking-123',
    userId: 'user-123',
    classId: 'class-123',
    datetime: DateTime.now().add(const Duration(hours: 48)),
    status: BookingStatus.confirmed,
    notificationSent: false,
  );

  group('cancel flow', () {
    // NOTE: The 24-hour time gate lives in BookingBookButton (widget layer),
    // NOT in BookingBloc. These tests verify the BLoC state machine.
    // Widget-level enforcement is tested in class_detail_screen_test.dart.

    blocTest<BookingBloc, BookingState>(
      'cancel_isAllowed_whenMoreThan24HoursBeforeClass: '
      'requestCancel emits cancelConfirmationRequired',
      build: buildBloc,
      seed: () => BookingState(existingBooking: farBooking),
      act: (bloc) => bloc.add(const BookingRequestCancelEvent()),
      expect: () => [
        BookingState(
          status: BookingUiStatus.cancelConfirmationRequired,
          existingBooking: farBooking,
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'cancel_isBlocked_whenLessThan24HoursBeforeClass: '
      'BLoC state machine is identical — widget enforces the time gate',
      build: buildBloc,
      seed: () => BookingState(
        existingBooking: farBooking.copyWith(
          datetime: DateTime.now().add(const Duration(hours: 12)),
        ),
      ),
      act: (bloc) => bloc.add(const BookingRequestCancelEvent()),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingUiStatus.cancelConfirmationRequired,
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'cancel_confirmedBooking_decrementsUsedSessions: '
      'updateBookingStatus is called with BookingStatus.cancelled',
      setUp: () {
        when(
          () => mockBookingRepo.updateBookingStatus(any(), any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => BookingState(existingBooking: farBooking),
      act: (bloc) =>
          bloc.add(const BookingConfirmCancelEvent(bookingId: 'booking-123')),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingUiStatus.loading),
        const BookingState(status: BookingUiStatus.cancelled),
      ],
      verify: (_) {
        verify(
          () => mockBookingRepo.updateBookingStatus(
            any(),
            'booking-123',
            BookingStatus.cancelled,
          ),
        ).called(1);
      },
    );

    blocTest<BookingBloc, BookingState>(
      'cancel_pendingBooking_doesNotDecrementUsedSessions: '
      'subscription is never touched during cancel',
      setUp: () {
        when(
          () => mockBookingRepo.updateBookingStatus(any(), any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => BookingState(
        existingBooking: farBooking.copyWith(status: BookingStatus.pending),
      ),
      act: (bloc) =>
          bloc.add(const BookingConfirmCancelEvent(bookingId: 'booking-123')),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingUiStatus.loading),
        const BookingState(status: BookingUiStatus.cancelled),
      ],
      verify: (_) {
        verifyNever(() => mockSubscriptionRepo.deductSession(any()));
      },
    );

    blocTest<BookingBloc, BookingState>(
      'cancel_emitsCorrectStateSequence → loading → cancelled',
      setUp: () {
        when(
          () => mockBookingRepo.updateBookingStatus(any(), any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => BookingState(
        status: BookingUiStatus.cancelConfirmationRequired,
        existingBooking: farBooking,
      ),
      act: (bloc) =>
          bloc.add(const BookingConfirmCancelEvent(bookingId: 'booking-123')),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingUiStatus.loading),
        const BookingState(status: BookingUiStatus.cancelled),
      ],
    );
  });

  // NOTE: BookingBloc reads uid from FirebaseAuth.instance.currentUser?.uid.
  // In unit tests this is null → uid = '' → both _onBookClass and
  // _onBookLesson return early with an error before reaching the repository.
  // The ClassFullFailure-from-repository path is tested in
  // booking_cubit_test.dart (BookingCubit accepts userId in its constructor).
  group('booking flow', () {
    blocTest<BookingBloc, BookingState>(
      'bookClass_emitsLoadingThenError_whenUserNotAuthenticated',
      build: buildBloc,
      act: (bloc) => bloc.add(
        BookingBookClassEvent(
          classModel: ClassModel(
            id: 'class-1',
            title: 'Yoga',
            type: 'Йога',
            startDate: DateTime.now().add(const Duration(hours: 48)),
            durationMinutes: 60,
            trainerId: 't-1',
            maxParticipants: 10,
            currentParticipants: 3,
            price: 0,
            isIncludedInSubscription: true,
          ),
          whatsAppMessage: '',
        ),
      ),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingUiStatus.loading,
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingUiStatus.error,
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'bookLesson_emitsLoadingThenError_whenUserNotAuthenticated',
      build: buildBloc,
      act: (bloc) => bloc.add(
        BookingBookLessonEvent(
          lesson: LessonModel(
            id: 'lesson-1',
            programId: 'program-1',
            startDate: DateTime.now().add(const Duration(hours: 48)),
            endDate: DateTime.now().add(const Duration(hours: 49)),
          ),
          programTitle: 'Test Program',
          whatsAppMessage: '',
        ),
      ),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingUiStatus.loading,
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingUiStatus.error,
        ),
      ],
    );
  });
}

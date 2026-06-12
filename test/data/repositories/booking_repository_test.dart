import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/core/utils/failure.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BookingRepository repo;

  const userId = 'user-abc';
  const classId = 'class-xyz';
  const lessonId = 'lesson-xyz';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = BookingRepository(firestore: fakeFirestore);
  });

  // Helper: path to the user-bookings subcollection.
  CollectionReference<Map<String, dynamic>> userBookings() => fakeFirestore
      .collection('bookings')
      .doc(userId)
      .collection('userBookings');

  group('createBooking', () {
    test('returns a pending BookingModel with correct fields', () async {
      final now = DateTime.now();
      final booking = await repo.createBooking(userId, classId, now);

      expect(booking.userId, userId);
      expect(booking.classId, classId);
      expect(booking.status, BookingStatus.pending);
      expect(booking.notificationSent, isFalse);
      expect(booking.id, isNotEmpty);
    });

    test('persists document in Firestore under bookings/{userId}/userBookings',
        () async {
      final now = DateTime.now();
      final booking = await repo.createBooking(userId, classId, now);

      final snap = await userBookings().doc(booking.id).get();
      expect(snap.exists, isTrue);
      expect(snap.data()?['classId'], classId);
      expect(snap.data()?['status'], 'pending');
    });

    test('createBooking_throwsClassFullFailure_whenClassIsFull', () async {
      await fakeFirestore
          .collection('classes')
          .doc(classId)
          .set({'currentParticipants': 5, 'maxParticipants': 5});

      await expectLater(
        () => repo.createBooking(userId, classId, DateTime.now()),
        throwsA(isA<ClassFullFailure>()),
      );
    });

    test('createBooking_succeeds_whenOneSpotLeft', () async {
      await fakeFirestore
          .collection('classes')
          .doc(classId)
          .set({'currentParticipants': 4, 'maxParticipants': 5});

      final booking = await repo.createBooking(userId, classId, DateTime.now());

      expect(booking.userId, userId);
      expect(booking.classId, classId);
      expect(booking.status, BookingStatus.pending);
    });
  });

  group('bookLesson', () {
    test('returns a pending BookingModel', () async {
      await fakeFirestore
          .collection('lessons')
          .doc(lessonId)
          .set({'currentParticipants': 0});

      final booking = await repo.bookLesson(
        userId,
        lessonId,
        DateTime.now(),
      );

      expect(booking.classId, lessonId);
      expect(booking.status, BookingStatus.pending);
    });

    test('bookLesson_incrementsCurrentParticipants', () async {
      await fakeFirestore
          .collection('lessons')
          .doc(lessonId)
          .set({'currentParticipants': 2});

      await repo.bookLesson(userId, lessonId, DateTime.now());

      final snap =
          await fakeFirestore.collection('lessons').doc(lessonId).get();
      expect(snap.data()?['currentParticipants'], 3);
    });

    test('bookLesson_throwsClassFullFailure_whenLessonIsFull', () async {
      await fakeFirestore
          .collection('lessons')
          .doc(lessonId)
          .set({'currentParticipants': 3, 'maxParticipants': 3});

      await expectLater(
        () => repo.bookLesson(userId, lessonId, DateTime.now()),
        throwsA(isA<ClassFullFailure>()),
      );
    });

    test('bookLesson_succeeds_whenOneSpotLeft', () async {
      await fakeFirestore
          .collection('lessons')
          .doc(lessonId)
          .set({'currentParticipants': 2, 'maxParticipants': 3});

      final booking =
          await repo.bookLesson(userId, lessonId, DateTime.now());

      expect(booking.classId, lessonId);
      expect(booking.status, BookingStatus.pending);
    });
  });

  group('updateBookingStatus', () {
    test('sets the status field on the booking document', () async {
      // Seed a pending booking.
      const bookingId = 'bk-1';
      await userBookings().doc(bookingId).set({
        'userId': userId,
        'classId': classId,
        'datetime': Timestamp.now(),
        'status': 'pending',
        'notificationSent': false,
      });

      await repo.updateBookingStatus(
        userId,
        bookingId,
        BookingStatus.cancelled,
      );

      final snap = await userBookings().doc(bookingId).get();
      expect(snap.data()?['status'], 'cancelled');
    });
  });

  group('getBookingForClass', () {
    test('returns existing active booking', () async {
      await userBookings().add({
        'userId': userId,
        'classId': classId,
        'datetime': Timestamp.now(),
        'status': 'pending',
        'notificationSent': false,
      });

      final result = await repo.getBookingForClass(userId, classId);
      expect(result, isNotNull);
      expect(result!.classId, classId);
    });

    test('returns null when no booking exists', () async {
      final result = await repo.getBookingForClass(
        userId,
        'non-existent-class',
      );
      expect(result, isNull);
    });

    test('ignores cancelled bookings', () async {
      await userBookings().add({
        'userId': userId,
        'classId': classId,
        'datetime': Timestamp.now(),
        'status': 'cancelled',
        'notificationSent': false,
      });

      final result = await repo.getBookingForClass(userId, classId);
      expect(result, isNull);
    });
  });
}

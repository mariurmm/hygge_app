import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class BookingRepository with RepositoryExecutorMixin {
  BookingRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userBookings(
    String userId,
  ) => _firestore
      .collection(CollectionNames.bookings)
      .doc(userId)
      .collection(CollectionNames.userBookings);

  Stream<List<BookingModel>> watchUserBookings(
    String userId,
  ) {
    return _userBookings(userId)
        .orderBy('datetime')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => BookingModel.fromJson(
                  doc.data(),
                  id: doc.id,
                ),
              )
              .toList(),
        )
        .handleError(
          _onStreamError(
            'BookingRepository.watchUserBookings',
          ),
        );
  }

  Future<BookingModel?> getBookingForClass(
    String userId,
    String classId,
  ) => execute(
    actionName: 'BookingRepository.getBookingForClass',
    action: () async {
      final snap = await _userBookings(userId)
          .where('classId', isEqualTo: classId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return BookingModel.fromJson(doc.data(), id: doc.id);
    },
  );

  Future<BookingModel> createBooking(
    String userId,
    String classId,
    DateTime datetime,
  ) => execute(
    actionName: 'BookingRepository.createBooking',
    action: () async {
      final ref = _userBookings(userId).doc();
      final booking = BookingModel(
        id: ref.id,
        userId: userId,
        classId: classId,
        datetime: datetime,
        status: BookingStatus.pending,
        notificationSent: false,
      );
      await ref.set(booking.toJson());
      return booking;
    },
  );

  Future<void> updateBookingStatus(
    String userId,
    String bookingId,
    BookingStatus status,
  ) => execute(
    actionName: 'BookingRepository.updateBookingStatus',
    action: () async {
      await _userBookings(
        userId,
      ).doc(bookingId).update({'status': status.name});
    },
  );

  Future<List<BookingModel>> getUpcomingBookings(String userId) => execute(
    actionName: 'BookingRepository.getUpcomingBookings',
    action: () async {
      final now = Timestamp.fromDate(DateTime.now());
      final snap = await _userBookings(
        userId,
      ).where('datetime', isGreaterThan: now).orderBy('datetime').get();

      return snap.docs
          .map((doc) => BookingModel.fromJson(doc.data(), id: doc.id))
          .where(
            (b) =>
                b.status == BookingStatus.pending ||
                b.status == BookingStatus.confirmed,
          )
          .toList();
    },
  );

  Future<List<BookingModel>> getBookingHistory(String userId) => execute(
    actionName: 'BookingRepository.getBookingHistory',
    action: () async {
      final now = Timestamp.fromDate(DateTime.now());
      final snap = await _userBookings(userId)
          .where('datetime', isLessThan: now)
          .orderBy('datetime', descending: true)
          .get();

      return snap.docs
          .map((doc) => BookingModel.fromJson(doc.data(), id: doc.id))
          .where((b) => b.status == BookingStatus.confirmed)
          .toList();
    },
  );

  Future<List<Map<String, dynamic>>> getPendingBookingsForNotification(
    String userId,
  ) => execute(
    actionName: 'BookingRepository.getPendingBookingsForNotification',
    action: () async {
      final now = Timestamp.fromDate(DateTime.now());
      final snap = await _userBookings(
        userId,
      ).where('datetime', isGreaterThan: now).get();

      return snap.docs
          .map(
            (doc) => {
              ...doc.data(),
              'bookingId': doc.id,
              'userId': userId,
            },
          )
          .where(
            (b) => b['status'] == 'pending' && b['notificationSent'] == false,
          )
          .toList();
    },
  );

  /// Creates a booking for a program lesson without checking class capacity.
  /// Use this for lessons from the programs catalog (not schedule classes).
  Future<BookingModel> bookLesson(
    String userId,
    String lessonId,
    DateTime datetime,
  ) =>
      execute(
        actionName: 'BookingRepository.bookLesson',
        action: () async {
          final bookingRef = _userBookings(userId).doc();
          final booking = BookingModel(
            id: bookingRef.id,
            userId: userId,
            classId: lessonId,
            datetime: datetime,
            status: BookingStatus.pending,
            notificationSent: false,
          );
          await bookingRef.set(booking.toJson());
          await _firestore
              .collection('lessons')
              .doc(lessonId)
              .update({'currentParticipants': FieldValue.increment(1)});
          return booking;
        },
      );

  Function _onStreamError(
    String actionName,
  ) =>
      (
        Object error,
        StackTrace st,
      ) => logError(
        actionName,
        error,
        st,
      );
}

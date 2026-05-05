import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BookingRepository {
  BookingRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userBookings(String userId) =>
      _firestore
          .collection(CollectionNames.bookings)
          .doc(userId)
          .collection(CollectionNames.userBookings);

  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return _userBookings(userId)
        .orderBy('datetime')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => BookingModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<BookingModel?> getBookingForClass(
    String userId,
    String classId,
  ) async {
    try {
      final snap = await _userBookings(userId)
          .where('classId', isEqualTo: classId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return BookingModel.fromJson(doc.data(), id: doc.id);
    } catch (e, st) {
      AppLogger.error(
        'BookingRepository: ошибка getBookingForClass',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<BookingModel> createBooking(
    String userId,
    String classId,
    DateTime datetime,
  ) async {
    try {
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
      AppLogger.info('BookingRepository: бронь создана ${ref.id}');
      return booking;
    } catch (e, st) {
      AppLogger.error(
        'BookingRepository: ошибка createBooking',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateBookingStatus(
    String userId,
    String bookingId,
    BookingStatus status,
  ) async {
    await _userBookings(userId).doc(bookingId).update({'status': status.name});
  }

  Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    try {
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
    } catch (e, st) {
      AppLogger.error(
        'BookingRepository: ошибка getUpcomingBookings',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<List<BookingModel>> getBookingHistory(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    try {
      final snap = await _userBookings(userId)
          .where('datetime', isLessThan: now)
          .orderBy('datetime', descending: true)
          .get();
      return snap.docs
          .map((doc) => BookingModel.fromJson(doc.data(), id: doc.id))
          .where((b) => b.status == BookingStatus.confirmed)
          .toList();
    } catch (e, st) {
      AppLogger.error(
        'BookingRepository: ошибка getBookingHistory',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingBookingsForNotification(
    String userId,
  ) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snap = await _userBookings(
      userId,
    ).where('datetime', isGreaterThan: now).get();
    return snap.docs
        .map((doc) => {...doc.data(), 'bookingId': doc.id, 'userId': userId})
        .where(
          (b) => b['status'] == 'pending' && b['notificationSent'] == false,
        )
        .toList();
  }
}

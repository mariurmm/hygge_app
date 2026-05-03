import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/collection_names.dart';
import '../../core/utils/logger.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userBookings(String userId) =>
      _firestore.collection(CollectionNames.bookings).doc(userId).collection(CollectionNames.userBookings);

  /// Стрим всех броней пользователя (активных и будущих).
  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return _userBookings(userId)
        .orderBy('datetime')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BookingModel.fromJson(doc.data(), id: doc.id)).toList());
  }

  /// Проверить, есть ли у пользователя бронь на занятие.
  Future<BookingModel?> getBookingForClass(String userId, String classId) async {
    try {
      final snap = await _userBookings(
        userId,
      ).where('classId', isEqualTo: classId).where('status', whereIn: ['pending', 'confirmed']).limit(1).get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return BookingModel.fromJson(doc.data(), id: doc.id);
    } catch (e, st) {
      AppLogger.error('BookingRepository: ошибка getBookingForClass', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Создать новую бронь.
  Future<BookingModel> createBooking(String userId, String classId, DateTime datetime) async {
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
      AppLogger.error('BookingRepository: ошибка createBooking', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Обновить статус брони.
  Future<void> updateBookingStatus(String userId, String bookingId, BookingStatus status) async {
    await _userBookings(userId).doc(bookingId).update({'status': status.name});
  }

  /// Предстоящие брони (pending/confirmed, datetime > now) — для HomeTab.
  Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    try {
      final snap = await _userBookings(userId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .where('datetime', isGreaterThan: now)
          .orderBy('datetime')
          .get();
      return snap.docs.map((doc) => BookingModel.fromJson(doc.data(), id: doc.id)).toList();
    } catch (e, st) {
      AppLogger.error('BookingRepository: ошибка getUpcomingBookings', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// История посещений (confirmed, datetime < now) — для ProfileTab.
  Future<List<BookingModel>> getBookingHistory(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    try {
      final snap = await _userBookings(userId)
          .where('status', isEqualTo: 'confirmed')
          .where('datetime', isLessThan: now)
          .orderBy('datetime', descending: true)
          .get();
      return snap.docs.map((doc) => BookingModel.fromJson(doc.data(), id: doc.id)).toList();
    } catch (e, st) {
      AppLogger.error('BookingRepository: ошибка getBookingHistory', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Все будущие брони со статусом pending (для планировщика уведомлений).
  Future<List<Map<String, dynamic>>> getPendingBookingsForNotification(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snap = await _userBookings(userId)
        .where('status', isEqualTo: 'pending')
        .where('notificationSent', isEqualTo: false)
        .where('datetime', isGreaterThan: now)
        .get();
    return snap.docs.map((doc) => {...doc.data(), 'bookingId': doc.id, 'userId': userId}).toList();
  }
}

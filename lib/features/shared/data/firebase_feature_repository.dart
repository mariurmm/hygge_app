import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

/// Единая точка чтения/записи Firestore для feature-слоя.
///
/// UI продолжает работать с существующими моделями:
/// - программы / расписание / история: [LessonModel]
/// - уведомления: [NotificationItem]
// ignore: unintended_html_in_doc_comment
/// - избранное: Set<String> uuid программ
class FirebaseFeatureRepository {
  FirebaseFeatureRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserModel> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String collection,
  ) => _firestore.collection('users').doc(uid).collection(collection);

  Future<List<LessonModel>> fetchPrograms({int? limit}) async {
    Query<Map<String, dynamic>> query = _programs.orderBy('startDate');
    if (limit != null) query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map(_lessonFromDocument).toList();
  }

  Stream<List<LessonModel>> watchPrograms({int? limit}) {
    Query<Map<String, dynamic>> query = _programs.orderBy('startDate');
    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_lessonFromDocument).toList(),
    );
  }

  Future<LessonModel?> fetchProgramById(String programId) async {
    if (programId.isEmpty) return null;
    final doc = await _programs.doc(programId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _lessonFromDocument(doc);
  }

  Future<List<LessonModel>> fetchBookings({String? status}) async {
    final uid = currentUserId;
    if (uid == null) return [];

    Query<Map<String, dynamic>> query = _userCollection(uid, 'bookings');
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    final result = <LessonModel>[];

    for (final doc in snapshot.docs) {
      final lesson = await _lessonFromBooking(doc);
      if (lesson != null) result.add(lesson);
    }

    result.sort((a, b) => a.startDate.compareTo(b.startDate));
    return result;
  }

  Future<void> bookProgram(LessonModel lesson) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _userCollection(uid, 'bookings').doc(lesson.uuid).set({
      'programId': lesson.uuid,
      'status': 'booked',
      'price': lesson.price,
      'bookedAt': FieldValue.serverTimestamp(),
      // Сохраняем snapshot программы, чтобы schedule/history не ломались,
      // даже если программа позже будет изменена или удалена.
      'lesson': lesson.toJson(),
    }, SetOptions(merge: true));
  }

  Stream<Set<String>> watchFavouriteIds() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(<String>{});

    return _userCollection(
      uid,
      'favourites',
    ).snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<Set<String>> fetchFavouriteIds() async {
    final uid = currentUserId;
    if (uid == null) return <String>{};

    final snapshot = await _userCollection(uid, 'favourites').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> setFavourite({
    required String programId,
    required bool isFavourite,
  }) async {
    final uid = currentUserId;
    if (uid == null || programId.isEmpty) return;

    final ref = _userCollection(uid, 'favourites').doc(programId);
    if (isFavourite) {
      await ref.set({
        'programId': programId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.delete();
    }
  }

  Stream<List<NotificationItem>> watchNotifications() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(const <NotificationItem>[]);

    return _userCollection(uid, 'notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_notificationFromDocument).toList(),
        );
  }

  Future<void> markNotificationAsRead(String id) async {
    final uid = currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(
      uid,
      'notifications',
    ).doc(id).set({'isRead': true}, SetOptions(merge: true));
  }

  Future<void> markAllNotificationsAsRead() async {
    final uid = currentUserId;
    if (uid == null) return;

    final snapshot = await _userCollection(
      uid,
      'notifications',
    ).where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.set(doc.reference, {'isRead': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> removeNotification(String id) async {
    final uid = currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(uid, 'notifications').doc(id).delete();
  }

  LessonModel _lessonFromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LessonModel.fromJson({...data, 'uuid': data['uuid'] ?? doc.id});
  }

  Future<LessonModel?> _lessonFromBooking(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();

    if (data['lesson'] is Map) {
      return LessonModel.fromJson({
        ...Map<String, dynamic>.from(data['lesson'] as Map),
        'uuid': data['programId'] ?? data['uuid'] ?? doc.id,
      });
    }

    final programId =
        data['programId'] as String? ?? data['lessonId'] as String?;
    if (programId == null || programId.isEmpty) return null;
    return fetchProgramById(programId);
  }

  NotificationItem _notificationFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return NotificationItem(
      id: doc.id,
      title: _localized(data['title']),
      body: _localized(data['body']),
      createdAt: _parseDate(data['createdAt']),
      isRead: data['isRead'] as bool? ?? false,
      type: _parseNotificationType(data['type']),
    );
  }

  NotificationType _parseNotificationType(dynamic value) {
    final raw = value?.toString() ?? '';
    return NotificationType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => NotificationType.system,
    );
  }

  String _localized(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return value['ru'] as String? ??
          value['en'] as String? ??
          value['kk'] as String? ??
          '';
    }
    return '';
  }

  DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

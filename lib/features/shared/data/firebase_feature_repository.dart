import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/profile_about_model.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

class FirebaseFeatureRepository {
  FirebaseFeatureRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<ProfileAboutModel> fetchProfileAbout({required String locale}) async {
    final doc = await _firestore
        .collection('app_content')
        .doc('profile_about')
        .get();

    if (!doc.exists || doc.data() == null) {
      return ProfileAboutModel.empty;
    }

    return ProfileAboutModel.fromJson(doc.data()!, locale: locale);
  }

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  CollectionReference<Map<String, dynamic>> get _upcomingPrograms =>
      _firestore.collection('upcoming_programs');

  CollectionReference<Map<String, dynamic>> get _lessons =>
      _firestore.collection('lessons');

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String collection,
  ) {
    return _firestore.collection('users').doc(uid).collection(collection);
  }

  Future<UserModel> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return UserModel.empty;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  Future<List<LessonModel>> fetchPrograms({int? limit}) async {
    Query<Map<String, dynamic>> query = _programs.where(
      'isActive',
      isEqualTo: true,
    );

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs.map(_lessonFromDocument).toList();
  }

  Stream<List<LessonModel>> watchPrograms({int? limit}) {
    Query<Map<String, dynamic>> query = _programs.where(
      'isActive',
      isEqualTo: true,
    );

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(_lessonFromDocument).toList(),
    );
  }

  Future<LessonModel?> fetchProgramById(String programId) async {
    if (programId.isEmpty) return null;

    final doc = await _programs.doc(programId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _lessonFromDocument(doc);
  }

  Future<List<LessonModel>> fetchUpcomingPrograms({int? limit}) async {
    final snapshot = await _upcomingPrograms
        .where('isVisible', isEqualTo: true)
        .get();

    final items =
        snapshot.docs
            .map(_lessonFromDocument)
            .where((program) => program.isNotEmpty)
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (limit == null || items.length <= limit) {
      return items;
    }

    return items.take(limit).toList();
  }

  Stream<List<LessonModel>> watchUpcomingPrograms({int? limit}) {
    return _upcomingPrograms
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final items =
              snapshot.docs
                  .map(_lessonFromDocument)
                  .where((program) => program.isNotEmpty)
                  .toList()
                ..sort((a, b) => a.startDate.compareTo(b.startDate));

          if (limit == null || items.length <= limit) {
            return items;
          }

          return items.take(limit).toList();
        });
  }

  Future<List<LessonModel>> fetchLessonsByProgramId(String programId) async {
    if (programId.isEmpty) return const <LessonModel>[];

    final snapshot = await _lessons
        .where('programId', isEqualTo: programId)
        .orderBy('startDate')
        .get();

    final result = <LessonModel>[];

    for (final doc in snapshot.docs) {
      final lesson = await _lessonWithProgramData(doc);
      if (lesson != null) {
        result.add(lesson);
      }
    }

    return result;
  }

  Future<List<LessonModel>> fetchUpcomingLessons({int limit = 10}) async {
    final now = Timestamp.fromDate(DateTime.now());

    final snapshot = await _lessons
        .where('startDate', isGreaterThan: now)
        .orderBy('startDate')
        .limit(limit)
        .get();

    final result = <LessonModel>[];

    for (final doc in snapshot.docs) {
      final lesson = await _lessonWithProgramData(doc);
      if (lesson != null) {
        result.add(lesson);
      }
    }

    return result;
  }

  Future<List<LessonModel>> fetchBookings({String? status}) async {
    final uid = currentUserId;
    if (uid == null) return const <LessonModel>[];

    Query<Map<String, dynamic>> query = _userCollection(uid, 'bookings');

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    final result = <LessonModel>[];

    for (final doc in snapshot.docs) {
      final lesson = await _lessonFromBooking(doc);
      if (lesson != null) {
        result.add(lesson);
      }
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

  Future<List<LessonModel>> fetchFavouritePrograms() async {
    final uid = currentUserId;
    if (uid == null) return const <LessonModel>[];

    final snapshot = await _userCollection(uid, 'favourites').get();
    final result = <LessonModel>[];

    for (final doc in snapshot.docs) {
      final programId = doc.id;
      final programDoc = await _programs.doc(programId).get();

      if (programDoc.exists && programDoc.data() != null) {
        result.add(_lessonFromDocument(programDoc));
      }
    }

    return result;
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

  Future<LessonModel?> _lessonWithProgramData(
    QueryDocumentSnapshot<Map<String, dynamic>> lessonDoc,
  ) async {
    final lessonData = lessonDoc.data();
    final programId = lessonData['programId'] as String?;

    if (programId == null || programId.isEmpty) {
      return LessonModel.fromJson({
        ...lessonData,
        'uuid': lessonData['uuid'] ?? lessonDoc.id,
      });
    }

    final programDoc = await _programs.doc(programId).get();

    if (!programDoc.exists || programDoc.data() == null) {
      return LessonModel.fromJson({
        ...lessonData,
        'uuid': lessonData['uuid'] ?? lessonDoc.id,
      });
    }

    final programData = programDoc.data()!;

    return LessonModel.fromJson({
      ...programData,
      ...lessonData,
      'uuid': lessonData['uuid'] ?? lessonDoc.id,
      'programId': programId,
      'title': programData['title'],
      'text': programData['text'],
      'ritual': programData['ritual'],
      'master': programData['master'],
      'price': lessonData['price'] ?? programData['price'],
    });
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

    if (programId == null || programId.isEmpty) {
      return null;
    }

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

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

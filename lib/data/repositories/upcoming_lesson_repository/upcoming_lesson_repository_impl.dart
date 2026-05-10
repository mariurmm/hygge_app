import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UpcomingLessonRepository)
class UpcomingLessonRepositoryImpl
    with RepositoryExecutorMixin
    implements UpcomingLessonRepository {
  UpcomingLessonRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  CollectionReference<Map<String, dynamic>> get _upcomingPrograms =>
      _firestore.collection('upcoming_programs');

  CollectionReference<Map<String, dynamic>> get _lessons =>
      _firestore.collection('lessons');

  CollectionReference<Map<String, dynamic>> _bookings(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookings');

  @override
  Future<List<LessonModel>> fetchUpcomingPrograms({int? limit}) => execute(
    actionName: 'UpcomingLessonRepository.fetchUpcomingPrograms',
    action: () async {
      final snapshot = await _upcomingPrograms
          .where('isVisible', isEqualTo: true)
          .get();

      final items =
          snapshot.docs.map(_lessonFromDoc).where((p) => p.isNotEmpty).toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

      return limit != null ? items.take(limit).toList() : items;
    },
  );

  @override
  Stream<List<LessonModel>> watchUpcomingPrograms({int? limit}) {
    return _upcomingPrograms
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final items =
              snapshot.docs
                  .map(_lessonFromDoc)
                  .where((p) => p.isNotEmpty)
                  .toList()
                ..sort((a, b) => a.startDate.compareTo(b.startDate));
          return limit != null ? items.take(limit).toList() : items;
        })
        .handleError(
          _onStreamError('UpcomingLessonRepository.watchUpcomingPrograms'),
        );
  }

  @override
  Future<List<LessonModel>> fetchLessonsByProgramId(String programId) =>
      execute(
        actionName: 'UpcomingLessonRepository.fetchLessonsByProgramId',
        action: () async {
          if (programId.isEmpty) return const <LessonModel>[];

          final now = Timestamp.fromDate(DateTime.now());
          final snapshot = await _lessons
              .where('programId', isEqualTo: programId)
              .where('startDate', isGreaterThanOrEqualTo: now)
              .orderBy('startDate')
              .get();

          final result = <LessonModel>[];
          for (final doc in snapshot.docs) {
            final lesson = await _lessonWithProgramData(doc);
            if (lesson != null) result.add(lesson);
          }
          return result;
        },
      );

  @override
  Future<List<LessonModel>> fetchUpcomingLessons({int limit = 10}) => execute(
    actionName: 'UpcomingLessonRepository.fetchUpcomingLessons',
    action: () async {
      final now = Timestamp.fromDate(DateTime.now());

      final snapshot = await _lessons
          .where('startDate', isGreaterThan: now)
          .orderBy('startDate')
          .limit(limit)
          .get();

      final result = <LessonModel>[];
      for (final doc in snapshot.docs) {
        final lesson = await _lessonWithProgramData(doc);
        if (lesson != null) result.add(lesson);
      }
      return result;
    },
  );

  @override
  Future<List<LessonModel>> fetchBookings({String? status}) => execute(
    actionName: 'UpcomingLessonRepository.fetchBookings',
    action: () async {
      final uid = _uid;
      if (uid == null) return const <LessonModel>[];

      var query = _bookings(uid) as Query<Map<String, dynamic>>;
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
    },
  );

  @override
  Future<void> bookProgram(LessonModel lesson) => execute(
    actionName: 'UpcomingLessonRepository.bookProgram',
    action: () async {
      final uid = _uid;
      if (uid == null) return;

      await _bookings(uid).doc(lesson.id).set({
        'lessonId': lesson.id,
        'programId': lesson.programId,
        'masterId': lesson.trainerId,
        'status': 'booked',
        'bookedAt': FieldValue.serverTimestamp(),
        'lesson': lesson.toJson(),
      }, SetOptions(merge: true));
    },
  );

  @override
  Future<void> cancelBooking(String bookingId) => execute(
    actionName: 'UpcomingLessonRepository.cancelBooking',
    action: () async {
      final uid = _uid;
      if (uid == null || bookingId.isEmpty) return;

      await _bookings(uid).doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    },
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  LessonModel _lessonFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
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
      final lesson = Map<String, dynamic>.from(data['lesson'] as Map);
      return LessonModel.fromJson({
        ...lesson,
        'uuid': data['lessonId'] ?? lesson['uuid'] ?? lesson['id'] ?? doc.id,
        'programId': data['programId'] ?? lesson['programId'],
      });
    }

    final lessonId = data['lessonId'] as String? ?? doc.id;
    if (lessonId.isEmpty) return null;

    final lessonDoc = await _lessons.doc(lessonId).get();
    if (lessonDoc.exists && lessonDoc.data() != null) {
      return _lessonFromDoc(lessonDoc);
    }

    final programId = data['programId'] as String?;
    if (programId == null || programId.isEmpty) return null;

    final programDoc = await _programs.doc(programId).get();
    if (!programDoc.exists || programDoc.data() == null) return null;
    return LessonModel.fromJson({
      ...programDoc.data()!,
      'uuid': lessonId,
      'programId': programId,
      'startDate': data['startDate'] ?? data['datetime'],
      'finishDate': data['finishDate'] ?? data['endDate'] ?? data['datetime'],
    });
  }

  Function _onStreamError(String actionName) =>
      (Object error, StackTrace st) => logError(actionName, error, st);
}

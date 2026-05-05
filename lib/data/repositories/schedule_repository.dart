import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ScheduleRepository {
  ScheduleRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<ClassModel>> watchUpcomingClasses() {
    return _firestore
        .collection(CollectionNames.classes)
        .where(
          'datetime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
        )
        .orderBy('datetime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClassModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Stream<List<ClassModel>> watchClassesForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _firestore
        .collection(CollectionNames.classes)
        .where('datetime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('datetime', isLessThan: Timestamp.fromDate(end))
        .orderBy('datetime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClassModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<ClassModel?> getClass(String classId) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.classes)
          .doc(classId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return ClassModel.fromJson(doc.data()!, id: doc.id);
    } catch (e, st) {
      AppLogger.error(
        'ScheduleRepository: ошибка getClass $classId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> incrementParticipants(String classId) async {
    final ref = _firestore.collection(CollectionNames.classes).doc(classId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Занятие не найдено: $classId');
      final data = snap.data();
      if (data == null) {
        throw Exception('Document not found at ${snap.reference.path}');
      }
      final current = (data['currentParticipants'] as num?)?.toInt() ?? 0;
      final max = (data['maxParticipants'] as num?)?.toInt() ?? 0;
      if (current >= max) throw Exception('Нет мест на занятии');
      tx.update(ref, {'currentParticipants': current + 1});
    });
  }

  Future<void> decrementParticipants(String classId) async {
    final ref = _firestore.collection(CollectionNames.classes).doc(classId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data();
      if (data == null) return;
      final current = (data['currentParticipants'] as num?)?.toInt() ?? 0;
      tx.update(ref, {'currentParticipants': current > 0 ? current - 1 : 0});
    });
  }
}

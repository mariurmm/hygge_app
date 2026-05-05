import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubscriptionRepository {
  SubscriptionRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection(CollectionNames.subscriptions).doc(userId);

  Stream<SubscriptionModel?> watchSubscription(String userId) {
    return _doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return SubscriptionModel.fromJson(snap.data()!);
    });
  }

  Future<SubscriptionModel?> getSubscription(String userId) async {
    try {
      final snap = await _doc(userId).get();
      if (!snap.exists || snap.data() == null) return null;
      return SubscriptionModel.fromJson(snap.data()!);
    } catch (e, st) {
      AppLogger.error(
        'SubscriptionRepository: ошибка getSubscription',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> deductSession(String userId) async {
    final ref = _doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw Exception('Абонемент не найден для $userId');
      }
      final data = snap.data()!;
      final used = (data['usedSessions'] as num?)?.toInt() ?? 0;
      final total = (data['totalSessions'] as num?)?.toInt() ?? 0;
      if (used >= total) {
        throw Exception('Занятия на абонементе закончились');
      }
      tx.update(ref, {'usedSessions': used + 1});
    });
  }

  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection(CollectionNames.users).doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    } on Exception catch (e, st) {
      AppLogger.error(
        'SubscriptionRepository: ошибка saveFcmToken',
        error: e,
        stackTrace: st,
      );
    }
  }
}

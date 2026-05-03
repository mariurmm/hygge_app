import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/collection_names.dart';
import '../../core/utils/logger.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection(CollectionNames.subscriptions).doc(userId);

  /// Стрим абонемента пользователя (real-time).
  Stream<SubscriptionModel?> watchSubscription(String userId) {
    return _doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return SubscriptionModel.fromJson(snap.data()!);
    });
  }

  /// Получить абонемент один раз.
  Future<SubscriptionModel?> getSubscription(String userId) async {
    try {
      final snap = await _doc(userId).get();
      if (!snap.exists || snap.data() == null) return null;
      return SubscriptionModel.fromJson(snap.data()!);
    } catch (e, st) {
      AppLogger.error('SubscriptionRepository: ошибка getSubscription', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Списать одно занятие (usedSessions + 1) — транзакция.
  Future<void> deductSession(String userId) async {
    final ref = _doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Абонемент не найден для $userId');
      final data = snap.data()!;
      final used = (data['usedSessions'] as num?)?.toInt() ?? 0;
      final total = (data['totalSessions'] as num?)?.toInt() ?? 0;
      if (used >= total) throw Exception('Занятия на абонементе закончились');
      tx.update(ref, {'usedSessions': used + 1});
    });
  }

  /// Сохранить FCM токен в документ пользователя.
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection(CollectionNames.users).doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e, st) {
      AppLogger.error('SubscriptionRepository: ошибка saveFcmToken', error: e, stackTrace: st);
    }
  }
}

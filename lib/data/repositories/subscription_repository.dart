import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/repository_executor.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SubscriptionRepository with RepositoryExecutorMixin {
  SubscriptionRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(
    String userId,
  ) => _firestore
      .collection(
        CollectionNames.subscriptions,
      )
      .doc(userId);

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  Stream<SubscriptionModel?> watchSubscription(
    String userId,
  ) {
    return _doc(userId)
        .snapshots()
        .map((snap) {
          if (!snap.exists || snap.data() == null) {
            return null;
          }

          return SubscriptionModel.fromJson(
            snap.data()!,
          );
        })
        .handleError(
          _onStreamError(
            'SubscriptionRepository.watchSubscription',
          ),
        );
  }

  Future<SubscriptionModel?> getSubscription(
    String userId,
  ) => execute(
    actionName: 'SubscriptionRepository.getSubscription',
    action: () async {
      final snap = await _doc(userId).get();

      if (!snap.exists || snap.data() == null) {
        return null;
      }

      return SubscriptionModel.fromJson(
        snap.data()!,
      );
    },
  );

  Future<void> deductSession(
    String userId,
  ) => execute(
    actionName: 'SubscriptionRepository.deductSession',
    action: () async {
      final ref = _doc(userId);

      await _firestore.runTransaction(
        (tx) async {
          final snap = await tx.get(ref);

          if (!snap.exists) {
            throw Exception(
              'Абонемент не найден для $userId',
            );
          }

          final data = snap.data();

          if (data == null) {
            throw Exception(
              'Document not found at ${snap.reference.path}',
            );
          }

          final used = (data['usedSessions'] as num?)?.toInt() ?? 0;

          final total = (data['totalSessions'] as num?)?.toInt() ?? 0;

          if (used >= total) {
            throw Exception(
              'Занятия на абонементе закончились',
            );
          }

          tx.update(
            ref,
            {
              'usedSessions': used + 1,
            },
          );
        },
      );
    },
  );

  Future<void> createDemoSubscription(
    String userId,
  ) => execute(
    actionName: 'SubscriptionRepository.createDemoSubscription',
    action: () async {
      await _doc(userId).set(
        {
          'userId': userId,
          'totalSessions': 999,
          'usedSessions': 0,
          'isActive': true,
          'purchaseDate': Timestamp.now(),
          'expirationDate': Timestamp.fromDate(
            DateTime.now().add(
              const Duration(
                days: 365,
              ),
            ),
          ),
        },
        SetOptions(
          merge: true,
        ),
      );
    },
  );

  Future<void> saveFcmToken(
    String userId,
    String token,
  ) => execute(
    actionName: 'SubscriptionRepository.saveFcmToken',
    action: () async {
      await _firestore
          .collection(
            CollectionNames.users,
          )
          .doc(userId)
          .set(
            {
              'fcmToken': token,
            },
            SetOptions(
              merge: true,
            ),
          );
    },
  );

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hygge_app/core/services/collection_names.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(CollectionNames.users)
          .doc(uid)
          .set(data, SetOptions(merge: true));

      AppLogger.info('Firestore: пользователь $uid сохранён');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Firestore: ошибка сохранения пользователя $uid',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        AppLogger.warning('Firestore: пользователь $uid не найден');
        return null;
      }

      return doc.data();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Firestore: ошибка получения пользователя $uid',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteUserDocument(String uid) async {
    try {
      await _firestore.collection(CollectionNames.users).doc(uid).delete();
      AppLogger.info('Firestore: пользователь $uid удалён');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Firestore: ошибка удаления пользователя $uid',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

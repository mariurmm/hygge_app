import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

import 'notification_repository.dart';

/// Implementation of [NotificationRepository] using Firebase Firestore.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userCollection(String uid, String collection) {
    return _firestore.collection('users').doc(uid).collection(collection);
  }

  @override
  Stream<List<NotificationItem>> watchNotifications() {
    final uid = _currentUserId;
    if (uid == null) return Stream.value(const <NotificationItem>[]);

    return _userCollection(uid, 'notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_notificationFromDocument).toList());
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    final uid = _currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(uid, 'notifications').doc(id).set({'isRead': true}, SetOptions(merge: true));
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final uid = _currentUserId;
    if (uid == null) return;

    final snapshot = await _userCollection(uid, 'notifications').where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.set(doc.reference, {'isRead': true}, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> removeNotification(String id) async {
    final uid = _currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(uid, 'notifications').doc(id).delete();
  }

  NotificationItem _notificationFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return NotificationItem(
      id: doc.id,
      title: _localized(data['title']),
      body: _localized(data['body']),
      createdAt: ParseUtils.parseDate(data['createdAt']),
      isRead: data['isRead'] as bool? ?? false,
      type: _parseNotificationType(data['type']),
    );
  }

  NotificationType _parseNotificationType(dynamic value) {
    final raw = value?.toString() ?? '';

    return NotificationType.values.firstWhere((type) => type.name == raw, orElse: () => NotificationType.system);
  }

  String _localized(dynamic value) {
    if (value is String) return value;

    if (value is Map) {
      return value['ru'] as String? ?? value['en'] as String? ?? value['kk'] as String? ?? '';
    }

    return '';
  }
}

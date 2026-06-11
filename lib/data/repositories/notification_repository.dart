import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:hygge_app/data/models/notification_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class NotificationRepository {
  NotificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String collection,
  ) => _firestore.collection('users').doc(uid).collection(collection);

  // ── Public API ────────────────────────────────────────────────

  Stream<List<NotificationItem>> watchNotifications() {
    final uid = _currentUserId;
    if (uid == null) return Stream.value(const <NotificationItem>[]);

    return _userCollection(uid, 'notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_notificationFromDocument).toList(),
        );
  }

  Future<void> markNotificationAsRead(String id) async {
    final uid = _currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(
      uid,
      'notifications',
    ).doc(id).set({'isRead': true}, SetOptions(merge: true));
  }

  Future<void> markAllNotificationsAsRead() async {
    final uid = _currentUserId;
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
    final uid = _currentUserId;
    if (uid == null || id.isEmpty) return;

    await _userCollection(uid, 'notifications').doc(id).delete();
  }

  // ── Helpers ──────────────────────────────────────────────────

  NotificationItem _notificationFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
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
}

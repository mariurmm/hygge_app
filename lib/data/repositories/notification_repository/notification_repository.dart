import 'package:hygge_app/data/models/notification_model.dart';

/// Interface for managing user notifications.
///
/// This repository handles:
/// - Fetching user notifications
/// - Marking notifications as read
/// - Removing notifications
abstract class NotificationRepository {
  /// Watch user notifications as a stream.
  ///
  ///Returns a stream of notification lists ordered by creation date (newest
  ///first).
  Stream<List<NotificationItem>> watchNotifications();

  /// Mark a specific notification as read.
  ///
  /// [id] - the unique identifier of the notification.
  Future<void> markNotificationAsRead(String id);

  /// Mark all notifications as read.
  Future<void> markAllNotificationsAsRead();

  /// Remove a notification.
  ///
  /// [id] - the unique identifier of the notification to remove.
  Future<void> removeNotification(String id);
}

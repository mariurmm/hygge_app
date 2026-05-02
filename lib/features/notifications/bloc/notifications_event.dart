part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

final class NotificationsInitialized extends NotificationsEvent {
  const NotificationsInitialized();
}

final class NotificationMarkedAsRead extends NotificationsEvent {
  const NotificationMarkedAsRead(this.id);
  final String id;
}

final class NotificationsMarkedAllAsRead extends NotificationsEvent {
  const NotificationsMarkedAllAsRead();
}

final class NotificationRemoved extends NotificationsEvent {
  const NotificationRemoved(this.id);
  final String id;
}

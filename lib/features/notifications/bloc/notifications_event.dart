part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

/// Событие для первоначальной загрузки данных
class LoadNotifications extends NotificationsEvent {}

/// Событие для смены статуса прочтения
class MarkNotificationAsRead extends NotificationsEvent {
  final String id;
  MarkNotificationAsRead(this.id);
}

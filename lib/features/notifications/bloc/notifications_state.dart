part of 'notifications_bloc.dart';

abstract class NotificationsState {}

/// Начальное состояние
class NotificationsInitial extends NotificationsState {}

/// Состояние процесса загрузки
class NotificationsLoading extends NotificationsState {}

/// Состояние с готовыми данными
class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;

  NotificationsLoaded({required this.notifications});
}

/// Состояние ошибки
class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError({required this.message});
}

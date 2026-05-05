// lib/features/notifications/bloc/notifications_state.dart

import 'package:equatable/equatable.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

class NotificationsState extends Equatable {
  const NotificationsState({this.items = const []});
  final List<NotificationItem> items;

  /// Непрочитанных уведомлений (для бейджа на иконке).
  int get unreadCount => items.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({List<NotificationItem>? items}) =>
      NotificationsState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}

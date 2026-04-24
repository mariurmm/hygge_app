// lib/features/notifications/bloc/notifications_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState()) {
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    // Сид-данные (потом заменить на Firestore)
    emit(NotificationsState(items: [
      NotificationItem(
        id: 'n1',
        title: 'Занятие через 30 минут',
        body: 'Утренняя медитация начинается в 8:00. Не забудьте коврик!',
        createdAt: now.subtract(const Duration(minutes: 25)),
        type: NotificationType.reminder,
      ),
      NotificationItem(
        id: 'n2',
        title: 'Запись подтверждена',
        body: 'Вы записаны на Йогу глубокого дыхания, 12 мая 10:00.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
        type: NotificationType.booking,
      ),
      NotificationItem(
        id: 'n3',
        title: 'Новая программа',
        body: 'Sound Bath — новая программа в расписании. Попробуйте!',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.news,
      ),
    ]));
  }

  /// Помечает одно уведомление прочитанным.
  void markAsRead(String id) {
    final updated = state.items
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(state.copyWith(items: updated));
  }

  /// Все уведомления — прочитаны.
  void markAllAsRead() {
    final updated = state.items
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(state.copyWith(items: updated));
  }

  /// Удаляет уведомление.
  void remove(String id) {
    emit(state.copyWith(
      items: state.items.where((n) => n.id != id).toList(),
    ));
  }
}
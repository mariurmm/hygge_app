import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(const NotificationsState()) {
    _subscription = _repository.watchNotifications().listen((items) {
      emit(NotificationsState(items: items));
    });
  }

  final FirebaseFeatureRepository _repository;
  StreamSubscription<List<NotificationItem>>? _subscription;

  Future<void> markAsRead(String id) async {
    final updated = state.items
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(state.copyWith(items: updated));
    await _repository.markNotificationAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: updated));
    await _repository.markAllNotificationsAsRead();
  }

  Future<void> remove(String id) async {
    emit(state.copyWith(
      items: state.items.where((n) => n.id != id).toList(),
    ));
    await _repository.removeNotification(id);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

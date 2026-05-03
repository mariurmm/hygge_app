import 'package:bloc/bloc.dart';
import 'package:hygge_app/data/repositories/notification_repository/notification_repository.dart';
import 'package:hygge_app/data/repositories/notification_repository/notification_repository_impl.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

part 'notifications_event.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepositoryImpl(),
      super(const NotificationsState()) {
    on<NotificationsInitialized>(_onInitialized);
    on<NotificationMarkedAsRead>(_onMarkAsRead);
    on<NotificationsMarkedAllAsRead>(_onMarkAllAsRead);
    on<NotificationRemoved>(_onRemove);
  }

  final NotificationRepository _repository;

  // emit.forEach keeps the handler alive for the stream's lifetime and
  // cancels the subscription automatically when the bloc is closed.
  Future<void> _onInitialized(NotificationsInitialized event, Emitter<NotificationsState> emit) {
    return emit.forEach<List<NotificationItem>>(
      _repository.watchNotifications(),
      onData: (items) => NotificationsState(items: items),
    );
  }

  Future<void> _onMarkAsRead(NotificationMarkedAsRead event, Emitter<NotificationsState> emit) async {
    final updated = state.items.map((n) => n.id == event.id ? n.copyWith(isRead: true) : n).toList();
    emit(state.copyWith(items: updated));
    await _repository.markNotificationAsRead(event.id);
  }

  Future<void> _onMarkAllAsRead(NotificationsMarkedAllAsRead event, Emitter<NotificationsState> emit) async {
    final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: updated));
    await _repository.markAllNotificationsAsRead();
  }

  Future<void> _onRemove(NotificationRemoved event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(items: state.items.where((n) => n.id != event.id).toList()));
    await _repository.removeNotification(event.id);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/notification_model.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationsLoading());

      try {
        await Future.delayed(const Duration(milliseconds: 500));

        final mockData = [
          NotificationModel(
            id: '1',
            type: NotificationType.welcome,
            date: DateTime.now(),
            isRead: false,
          ),
        ];

        emit(NotificationsLoaded(notifications: mockData));
      } catch (_) {
        emit(NotificationsError(message: 'notificationsLoadError'));
      }
    });

    on<MarkNotificationAsRead>((event, emit) {
      if (state is NotificationsLoaded) {
        final current = (state as NotificationsLoaded).notifications;

        final updated = current.map((n) {
          return n.id == event.id ? n.copyWith(isRead: true) : n;
        }).toList();

        emit(NotificationsLoaded(notifications: updated));
      }
    });
  }
}

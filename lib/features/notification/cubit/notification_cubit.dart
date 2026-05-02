import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

// FCM / Push-уведомления подключаются после активации Blaze-плана.
// Сейчас Cubit является заглушкой — не вызывает firebase_messaging.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  // Вызывается из роутера; пока ничего не делает.
  void initialize() {}
}

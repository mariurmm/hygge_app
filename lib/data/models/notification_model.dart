enum NotificationType { welcome, programReminder, systemUpdate }

class NotificationModel {
  final String id;
  final NotificationType type;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.date,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      date: date,
      isRead: isRead ?? this.isRead,
    );
  }
}

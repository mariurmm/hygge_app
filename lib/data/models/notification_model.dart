enum NotificationType {
  welcome,
  programReminder,
  systemUpdate,
}

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

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    DateTime? date,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
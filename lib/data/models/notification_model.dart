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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? json['uuid'] as String? ?? '',
      type: _parseType(json['type']),
      date: _parseDate(json['date'] ?? json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      date: date,
      isRead: isRead ?? this.isRead,
    );
  }

  static NotificationType _parseType(dynamic value) {
    final raw = value?.toString();
    return NotificationType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => NotificationType.systemUpdate,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}

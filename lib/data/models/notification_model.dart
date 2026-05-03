import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

class NotificationModel {
  final String id;
  final NotificationType type;
  final DateTime date;
  final bool isRead;

  NotificationModel({required this.id, required this.type, required this.date, this.isRead = false});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? json['uuid'] as String? ?? '',
      type: _parseType(json['type']),
      date: ParseUtils.parseDate(json['date'] ?? json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.name, 'date': date.toIso8601String(), 'isRead': isRead};
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(id: id, type: type, date: date, isRead: isRead ?? this.isRead);
  }

  static NotificationType _parseType(dynamic value) {
    final raw = value?.toString();
    return NotificationType.values.firstWhere((type) => type.name == raw, orElse: () => NotificationType.system);
  }
}

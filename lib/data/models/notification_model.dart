import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';

part 'notification_model.freezed.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required NotificationType type,
    required DateTime date,
    @Default(false) bool isRead,
  }) = _NotificationModel;

  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? json['uuid'] as String? ?? '',
      type: _parseType(json['type']),
      date: ParseUtils.parseDate(json['date'] ?? json['createdAt']),
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

  static NotificationType _parseType(dynamic value) {
    final raw = value?.toString();
    return NotificationType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => NotificationType.system,
    );
  }
}

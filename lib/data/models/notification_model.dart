import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hygge_app/core/utils/parse_utils.dart';

part 'notification_model.freezed.dart';

enum NotificationType { reminder, news, booking, system }

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    type: type,
  );

  @override
  List<Object?> get props => [id, title, body, createdAt, isRead, type];
}

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

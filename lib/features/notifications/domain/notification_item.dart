// lib/features/notifications/domain/notification_item.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationType { reminder, news, booking, system }

@immutable
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

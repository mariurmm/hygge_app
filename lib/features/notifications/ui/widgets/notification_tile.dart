// lib/features/notifications/ui/widgets/notification_tile.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/features/notifications/domain/notification_item.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, required this.onTap, required this.onDismiss});

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: _DismissBackground(),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.isRead
                    ? AppColors.programsCard.withValues(alpha: 0.5)
                    : AppColors.programsCard.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: item.isRead ? 0.1 : 0.2),
                  width: AppConstants.programsBorderWidth,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Иконка типа уведомления
                  _TypeIcon(type: item.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.programsCardTitle.copyWith(
                                  color: item.isRead ? Colors.white60 : Colors.white,
                                ),
                              ),
                            ),
                            // Индикатор непрочитанного
                            if (!item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8, top: 4),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.terracotta),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: AppTextStyles.programsCardDescription.copyWith(
                            color: item.isRead ? Colors.white38 : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_formatTime(item.createdAt), style: AppTextStyles.label.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    return DateFormat('d MMM', 'ru').format(dt);
  }
}

// Иконка зависит от типа уведомления
class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});
  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      NotificationType.reminder => (Icons.access_time_rounded, AppColors.lightBrown),
      NotificationType.booking => (Icons.event_available_rounded, AppColors.green),
      NotificationType.news => (Icons.campaign_rounded, AppColors.beige),
      NotificationType.system => (Icons.info_outline_rounded, AppColors.darkBlue),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

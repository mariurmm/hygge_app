import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_paddings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/notifications_bloc.dart';
import '../../../data/models/notification_model.dart';
import '../../../widgets/tab_header.dart';

class NotificationTab extends StatelessWidget {
  const NotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationView();
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/png/background1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const ProgramsHeader(),

                Expanded(
                  child: BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (state is NotificationsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      if (state is NotificationsLoaded) {
                        if (state.notifications.isEmpty) {
                          return Center(
                            child: Text(
                              loc.notificationEmptyState,
                              style: const TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(
                            AppPaddings.programsScreenHorizontal,
                          ),
                          itemCount: state.notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final n = state.notifications[index];

                            return _NotificationCard(
                              title: _title(n.type, loc),
                              description: _description(n.type, loc),
                              date: _formatDate(n.date),
                              isRead: n.isRead,
                              onTap: () {
                                context.read<NotificationsBloc>().add(
                                  MarkNotificationAsRead(n.id),
                                );
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(NotificationType type, AppLocalizations loc) {
    switch (type) {
      case NotificationType.welcome:
        return loc.notificationWelcomeTitle;
      case NotificationType.programReminder:
        return loc.notificationProgramReminderTitle;
      case NotificationType.systemUpdate:
        return loc.notificationSystemUpdateTitle;
    }
  }

  String _description(NotificationType type, AppLocalizations loc) {
    switch (type) {
      case NotificationType.welcome:
        return loc.notificationWelcomeDesc;
      case NotificationType.programReminder:
        return loc.notificationProgramReminderDesc;
      case NotificationType.systemUpdate:
        return loc.notificationSystemUpdateDesc;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.description,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.programsCardTitle),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.programsCardDescription.copyWith(
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(0xFFE08564),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

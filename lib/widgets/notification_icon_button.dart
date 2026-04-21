import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/bloc/notifications_bloc.dart';
import '../core/router/route_names.dart'; // Импорт имен роутов
import '../core/constants/app_constants.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        bool hasUnread = false;
        if (state is NotificationsLoaded) {
          hasUnread = state.notifications.any((n) => !n.isRead);
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: Colors.white,
                size: AppConstants.programsHeaderIconSize,
              ),
              onPressed: () {
                // Используем pushNamed для перехода по имени
                context.pushNamed(RouteNames.notificationsName);
              },
            ),
            if (hasUnread)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE08564),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

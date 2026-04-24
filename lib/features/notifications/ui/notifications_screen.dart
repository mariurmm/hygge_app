// lib/features/notifications/ui/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_cubit.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/features/notifications/ui/widgets/notification_tile.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AssetPaths.homeBackground,
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Хедер с кнопкой «Прочитать все» ──
                    ProgramsHeader(
                      leading: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home/main');
                          }
                        },
                      ),
                      trailing: state.hasUnread
                          ? TextButton(
                              onPressed: cubit.markAllAsRead,
                              child: Text(
                                'Прочитать все',
                                style: AppTextStyles.settingsChangePhoto,
                              ),
                            )
                          : null,
                    ),

                    Expanded(
                      child: state.items.isEmpty
                          ? _EmptyNotifications()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.profileCardsBottomInset,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppPaddings.profileScreenHorizontal,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Уведомления',
                                      style: AppTextStyles.programsHeading,
                                    ),
                                    const SizedBox(
                                      height: AppSpacings.programsLeadGap,
                                    ),
                                    // Бейдж с количеством непрочитанных
                                    if (state.hasUnread)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacings.programsCardsGap,
                                        ),
                                        child: Text(
                                          '${state.unreadCount} непрочитанных',
                                          style: AppTextStyles.programsSubtitle,
                                        ),
                                      ),
                                    // Список уведомлений
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: state.items.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(
                                            height:
                                                AppSpacings.programsCardsGap,
                                          ),
                                      itemBuilder: (context, index) {
                                        final item = state.items[index];
                                        return NotificationTile(
                                          item: item,
                                          onTap: () =>
                                              cubit.markAsRead(item.id),
                                          onDismiss: () =>
                                              cubit.remove(item.id),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white38,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text('Нет уведомлений', style: AppTextStyles.programsSubtitle),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/repositories/notification_repository/notification_repository.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';
import 'package:hygge_app/features/notifications/ui/widgets/notification_tile.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/tab_header.dart';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationsBloc(repository: context.read<NotificationRepository>())
            ..add(const NotificationsInitialized()),
      child: const _NotificationsView(),
    );
  }

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
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
                    ProgramsHeader(
                      leading: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth:
                              40, //в AppConstants сделай переменной, типа IconButtonMinSiz
                          minHeight: 40, //такие это хардкод, так нельзя
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: AppConstants.iconSizeMd,
                        ),
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(RouteNames.main),
                      ),
                      trailing: state.hasUnread
                          ? TextButton(
                              onPressed: () => context
                                  .read<NotificationsBloc>()
                                  .add(const NotificationsMarkedAllAsRead()),
                              child: Text(
                                loc.readAll,
                                style: AppTextStyles.settingsChangePhoto,
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: state.items.isEmpty
                          ? const _EmptyNotifications()
                          : _NotificationsList(state: state),
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

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: AppConstants.profileCardsBottomInset,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPaddings.profileScreenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.notifications, style: AppTextStyles.programsHeading),
            const SizedBox(height: AppSpacings.programsLeadGap),
            if (state.hasUnread) ...[
              Text(
                loc.unreadNotifications(state.unreadCount),
                style: AppTextStyles.programsSubtitle,
              ),
              const SizedBox(height: AppSpacings.programsCardsGap),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacings.programsCardsGap),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return NotificationTile(
                  item: item,
                  onTap: () => context.read<NotificationsBloc>().add(
                    NotificationMarkedAsRead(item.id),
                  ),
                  onDismiss: () => context.read<NotificationsBloc>().add(
                    NotificationRemoved(item.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white38,
            size: AppConstants.iconSizeHero,
          ),
          const SizedBox(height: AppSpacings.md),
          Text(
            AppLocalizations.of(context).noNotifications,
            style: AppTextStyles.programsSubtitle,
          ),
        ],
      ),
    );
  }
}

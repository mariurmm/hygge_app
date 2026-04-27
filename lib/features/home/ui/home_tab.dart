import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';

import 'package:hygge_app/widgets/tab_header.dart';

import 'package:hygge_app/features/programs_list/ui/programm_card.dart';

import 'package:hygge_app/features/home/bloc/home_bloc.dart';
import 'package:hygge_app/features/home/bloc/home_event.dart';
import 'package:hygge_app/features/home/bloc/home_state.dart';

import 'package:hygge_app/features/notifications/bloc/notifications_cubit.dart';
import 'package:hygge_app/features/notifications/bloc/notifications_state.dart';

import '../../../l10n/generated/app_localizations.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(HomeLoadRequested()),
      child: const _MainTabView(),
    );
  }
}

class _MainTabView extends StatelessWidget {
  const _MainTabView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                ProgramsHeader(trailing: _NotificationsBell()),

                // ================= BODY =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                            top: 8,
                            right: AppPaddings.programsScreenHorizontal,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.programsHeading,
                              children: [
                                TextSpan(text: loc.homeHeadlinePart1),
                                TextSpan(
                                  text: loc.homeHeadlineAccent,
                                  style: AppTextStyles.programsHeading.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFE08564),
                                  ),
                                ),
                                TextSpan(text: loc.homeHeadlinePart2),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeAnnouncements,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/png/banner.png',
                                  width: double.infinity,
                                  height: 218,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 16,
                                  child: Text(
                                    loc.readOurNews,
                                    style: AppTextStyles.programsFilter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeUpcomingPrograms,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return SizedBox(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppPaddings.programsScreenHorizontal,
                                ),
                                itemCount: state.lessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = state.lessons[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: ProgrammCard(
                                      type: ProgrammCardType.small,
                                      lesson: lesson,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== NOTIFICATIONS WIDGET =====================
/// изолирован, чтобы не ломал экран
class _NotificationsBell extends StatelessWidget {
  const _NotificationsBell();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit?>();

    if (cubit == null) {
      return IconButton(
        onPressed: () => context.go('/home/notifications'),
        icon: SvgPicture.asset(
          'assets/svg/notification.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      );
    }

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: cubit,
      builder: (context, state) {
        final hasUnread = state.hasUnread;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.go('/home/notifications'),
              icon: SvgPicture.asset(
                AssetPaths.notificationIcon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

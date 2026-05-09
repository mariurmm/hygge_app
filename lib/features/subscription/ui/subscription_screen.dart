import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/subscription/cubit/subscription_cubit.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AssetPaths.homeBackground,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgramsHeader(
                  showLogo: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AppConstants.programsHeaderLogoSize,
                      minHeight: AppConstants.programsHeaderLogoSize,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Image.asset(
                      AssetPaths.arrowBack,
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: AppConstants.iconSizeMd,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, state) {
                      if (state.status == SubscriptionStatus.initial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (state.subscription == null) {
                        return const _EmptySubscription();
                      }

                      return _SubscriptionContent(state: state);
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
}

class _SubscriptionContent extends StatelessWidget {
  const _SubscriptionContent({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final sub = state.subscription!;
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final remaining = sub.remainingSessions;

    final progress = sub.totalSessions > 0
        ? sub.usedSessions / sub.totalSessions
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Занятий осталось',
                      style: AppTextStyles.scheduleCardLabel,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sub.isValid
                            ? AppColors.primary.withValues(alpha: 0.7)
                            : AppColors.terracotta.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sub.isValid ? 'Активен' : 'Истёк',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$remaining',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 56,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'из ${sub.totalSessions}',
                  style: AppTextStyles.scheduleCardLabel,
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.progressFillStart,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  label: 'Действует до',
                  value: dateFormat.format(sub.endDate),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Начало',
                  value: dateFormat.format(sub.startDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (sub.isExpired)
            _GlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.terracotta,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Абонемент истёк. '
                      'Обратитесь к администратору для продления.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
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

class _EmptySubscription extends StatelessWidget {
  const _EmptySubscription();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.card_membership,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Абонемент не найден',
                style: AppTextStyles.scheduleCalendarTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Для приобретения абонемента обратитесь '
                'к администратору студии.',
                style: AppTextStyles.scheduleCardLabel,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppConstants.scheduleCardRadius,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.scheduleCard.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(
              AppConstants.scheduleCardRadius,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.scheduleCardLabel,
        ),
        Text(
          value,
          style: AppTextStyles.scheduleCardLabel.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

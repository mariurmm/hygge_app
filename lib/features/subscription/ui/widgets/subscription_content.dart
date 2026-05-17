import 'package:flutter/material.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/subscription/bloc/subscription_bloc.dart';
import 'package:hygge_app/features/subscription/ui/widgets/subscription_glass_card.dart';
import 'package:hygge_app/features/subscription/ui/widgets/subscription_info_row.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class SubscriptionContent extends StatelessWidget {
  const SubscriptionContent({
    required this.state,
    required this.loc,
    super.key,
  });

  final SubscriptionState state;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final sub = state.subscription!;
    final dateFormat = DateFormat('d MMMM yyyy', loc.localeName);
    final remaining = sub.remainingSessions;
    final progress = sub.totalSessions > 0
        ? sub.usedSessions / sub.totalSessions
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubscriptionGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.subscriptionLessonsLeftLabel,
                      style: AppTextStyles.scheduleCardLabel,
                    ),
                    _StatusBadge(isValid: sub.isValid, loc: loc),
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
                  loc.subscriptionOutOf(sub.totalSessions),
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
                SubscriptionInfoRow(
                  label: loc.subscriptionValidUntilLabel,
                  value: dateFormat.format(sub.endDate),
                ),
                const SizedBox(height: 8),
                SubscriptionInfoRow(
                  label: loc.subscriptionStartLabel,
                  value: dateFormat.format(sub.startDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!sub.isValid)
            SubscriptionGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.terracotta,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sub.isExpired
                              ? loc.subscriptionExpiredNotice
                              : loc.subscriptionNoSessionsNotice,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => getIt<WhatsAppService>().open(
                        loc.whatsAppNoLessonsLeft,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.85),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        loc.subscriptionRenewButton,
                        style: AppTextStyles.button,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isValid, required this.loc});

  final bool isValid;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isValid
            ? AppColors.primary.withValues(alpha: 0.7)
            : AppColors.terracotta.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isValid ? loc.subscriptionActive : loc.subscriptionExpired,
        style: AppTextStyles.label.copyWith(color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/di/injection.dart';
import 'package:hygge_app/features/subscription/ui/widgets/subscription_glass_card.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class SubscriptionEmpty extends StatelessWidget {
  const SubscriptionEmpty({required this.loc, super.key});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SubscriptionGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_membership, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                loc.subscriptionNotFound,
                style: AppTextStyles.scheduleCalendarTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.subscriptionContactAdmin,
                style: AppTextStyles.scheduleCardLabel,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => getIt<WhatsAppService>().open(
                    loc.whatsAppBuySubscription,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.85),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(loc.subscriptionBuy, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
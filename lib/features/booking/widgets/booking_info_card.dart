import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/widgets/booking_glass_card.dart';
import 'package:hygge_app/features/subscription/bloc/subscription_bloc.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class BookingInfoCard extends StatelessWidget {
  const BookingInfoCard({
    required this.classModel,
    required this.loc,
    super.key,
  });

  final ClassModel classModel;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    if (!classModel.isIncludedInSubscription) {
      return BookingGlassCard(
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white70, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.externalEventNotice,
                style:
                    AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        if (subState.hasActiveSubscription) return const SizedBox.shrink();
        return BookingGlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.card_membership,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.subscriptionRequired,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

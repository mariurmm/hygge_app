import 'package:flutter/material.dart';
// TODO(mvp): restore after MVP
// import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
// TODO(mvp): restore after MVP
// import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';
// TODO(mvp): restore after MVP
// import 'package:hygge_app/features/profile/ui/widgets/profile_account_subscription_card.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_monthly_travel_card.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProfileStatusSection extends StatelessWidget {
  const ProfileStatusSection({
    required this.state,
    required this.loc,
    super.key,
  });
  final ProfileState state;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.profileScreenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.isPremium
                ? loc.profileStatusPremium
                : loc.profileStatusStandard,
            style: AppTextStyles.programsSubtitle,
          ),
          const SizedBox(
            height: AppSpacings.profileStatusNameGap,
          ),
          Text(
            state.displayName,
            style: AppTextStyles.programsHeading,
          ),
          const SizedBox(
            height: AppSpacings.profileNameCardGap,
          ),
          // TODO(mvp): restore after MVP
          // ProfileAccountSubscriptionCard(
          //   onTap: () => context.push(RouteNames.subscription),
          // ),
          // const SizedBox(height: AppSpacings.profileCardsVerticalGap),
          ProfileMonthlyTravelCard(
            percent: state.travelProgressPercent,
            description: loc.profileMonthlySessionsCompleted(
              state.sessionsCompletedThisMonth,
            ),
            goalLine: loc.profileGoalSessions(
              state.goalSessionsTotal,
            ),
          ),
        ],
      ),
    );
  }
}

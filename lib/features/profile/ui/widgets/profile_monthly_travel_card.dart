import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_travel_progress_bar.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProfileMonthlyTravelCard extends StatelessWidget {
  const ProfileMonthlyTravelCard({
    required this.percent,
    required this.description,
    required this.goalLine,
    super.key,
  });
  final int percent;
  final String description;
  final String goalLine;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.programsBlurSigma,
          sigmaY: AppConstants.programsBlurSigma,
        ),
        child: Container(
          width: AppConstants.profileCardWidth,
          decoration: BoxDecoration(
            color: AppColors.scheduleCard.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(
              AppConstants.scheduleCardRadius,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(AppPaddings.profileMonthlyCardInner),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      loc.profileMonthlyTitle,
                      style: AppTextStyles.scheduleCardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacings.profileMonthlyTitlePercentGap,
                  ),
                  Text('$percent%', style: AppTextStyles.scheduleCardTitle),
                ],
              ),
              const SizedBox(height: AppSpacings.profileMonthlyTitleDescGap),
              Text(description, style: AppTextStyles.scheduleCardLabel),
              const SizedBox(height: AppSpacings.profileMonthlyDescProgressGap),
              ProfileTravelProgressBar(percent: percent),
              const SizedBox(
                height: AppSpacings.profileMonthlyProgressFooterGap,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  goalLine,
                  style: AppTextStyles.scheduleCardLabel,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

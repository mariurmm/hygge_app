import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_travel_progress_bar.dart';

class ProfileMonthlyTravelCard extends StatelessWidget {
  final int percent;
  final String description;
  final String leftSessionsLine;
  final String goalLine;

  const ProfileMonthlyTravelCard({
    super.key,
    required this.percent,
    required this.description,
    required this.leftSessionsLine,
    required this.goalLine,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.programsBlurSigma,
          sigmaY: AppConstants.programsBlurSigma,
        ),
        child: Container(
          width: AppConstants.profileCardWidth,
          height: AppConstants.profileMonthlyTravelCardHeight,
          decoration: BoxDecoration(
            color: AppColors.scheduleCard.withValues(alpha: 0.82),
            borderRadius:
                BorderRadius.circular(AppConstants.scheduleCardRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: AppConstants.programsBorderWidth,
            ),
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
                      'Ежемесячное путешествие',
                      style: AppTextStyles.scheduleCardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacings.profileMonthlyTitlePercentGap),
                  Text('$percent%', style: AppTextStyles.scheduleCardTitle),
                ],
              ),
              SizedBox(height: AppSpacings.profileMonthlyTitleDescGap),
              Text(
                description,
                style: AppTextStyles.scheduleCardLabel,
              ),
              SizedBox(height: AppSpacings.profileMonthlyDescProgressGap),
              ProfileTravelProgressBar(percent: percent),
              SizedBox(height: AppSpacings.profileMonthlyProgressFooterGap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppConstants.profileMonthlyLeftTextMaxWidth,
                    height: AppConstants.profileMonthlyLeftTextMaxHeight,
                    child: Text(
                      leftSessionsLine,
                      style: AppTextStyles.scheduleCardLabel.copyWith(
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacings.profileMonthlyLeftGoalGap),
                  Expanded(
                    child: Text(
                      goalLine,
                      style: AppTextStyles.scheduleCardLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

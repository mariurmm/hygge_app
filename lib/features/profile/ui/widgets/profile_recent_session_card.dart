import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProfileRecentSessionCard extends StatelessWidget {
  final String timingLabel;
  final String imageAssetPath;

  const ProfileRecentSessionCard({super.key, required this.timingLabel, required this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConstants.programsBlurSigma, sigmaY: AppConstants.programsBlurSigma),
        child: Container(
          width: AppConstants.profileCardWidth,
          height: AppConstants.profileRecentHistoryCardHeight,
          decoration: BoxDecoration(
            color: AppColors.programsCard.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: AppConstants.programsBorderWidth),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  imageAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.programsCardMedia),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0.55)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppPaddings.profileRecentSessionTimeLeft,
                top: AppPaddings.profileRecentSessionTimeTop,
                child: Text(timingLabel, style: AppTextStyles.scheduleCardLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

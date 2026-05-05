import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ScheduleProgressCard extends StatelessWidget {
  final int percent;
  final String description;

  const ScheduleProgressCard({
    super.key,
    required this.percent,
    required this.description,
  });

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
          width: AppConstants.scheduleCardWidth,
          height: AppConstants.scheduleCardHeight,
          decoration: BoxDecoration(
            color: AppColors.scheduleCard.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(
              AppConstants.scheduleCardRadius,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: AppConstants.programsBorderWidth,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    loc.progressLabel,
                    style: AppTextStyles.scheduleCardTitle,
                  ),
                  const Spacer(),
                  Text('$percent%', style: AppTextStyles.scheduleCardTitle),
                ],
              ),
              const SizedBox(height: AppSpacings.sm),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final p = (percent / 100).clamp(0.0, 1.0);
                        final fillW =
                            (c.maxWidth - 5).clamp(0.0, c.maxWidth) * p;
                        return Stack(
                          children: [
                            Container(
                              width: c.maxWidth,
                              height: AppConstants.scheduleProgressStrokeHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.progressStroke,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 2.5,
                              top: 2.5,
                              child: Container(
                                width: fillW,
                                height: AppConstants.scheduleProgressFillHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.progressFillStart,
                                      AppColors.progressFillEnd,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: AppTextStyles.scheduleProgressPercent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacings.scheduleProgressDescGap),
              Text(
                description,
                style: AppTextStyles.scheduleCardLabel.copyWith(height: 1.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

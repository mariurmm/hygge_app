import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ScheduleProgramCard extends StatelessWidget {
  final String ritual;
  final String title;
  final String timeRange;
  final String whenLabel;

  const ScheduleProgramCard({
    super.key,
    required this.ritual,
    required this.title,
    required this.timeRange,
    required this.whenLabel,
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppPaddings.scheduleCardIconLeft,
                  top: AppPaddings.scheduleCardIconTop,
                  bottom: AppPaddings.scheduleCardIconBottom,
                ),
                child: SvgPicture.asset(
                  AssetPaths.programsLogo,
                  width: AppConstants.scheduleProgramsIconWidth,
                  height: AppConstants.scheduleProgramsIconHeight,
                ),
              ),

              const SizedBox(width: AppSpacings.scheduleCardTextGapH),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppPaddings.scheduleCardTextTop,
                    right: AppPaddings.scheduleCardIconLeft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ritual,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.scheduleCardLabel,
                      ),

                      const SizedBox(height: AppSpacings.scheduleCardTextGapV),

                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.scheduleCardTitle,
                      ),

                      const SizedBox(height: AppSpacings.programsFiltersGap),

                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              timeRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.scheduleCardLabel,
                            ),
                          ),

                          const SizedBox(
                            width: AppSpacings.scheduleCardBottomRowGap,
                          ),

                          Flexible(
                            child: Text(
                              whenLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.scheduleCardLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

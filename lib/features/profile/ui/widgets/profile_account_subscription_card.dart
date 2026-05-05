import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ProfileAccountSubscriptionCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ProfileAccountSubscriptionCard({super.key, this.onTap});

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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: AppConstants.profileCardWidth,
              height: AppConstants.profileAccountCardHeight,
              decoration: BoxDecoration(
                color: AppColors.profileAccountCardFill,
                borderRadius: BorderRadius.circular(
                  AppConstants.scheduleCardRadius,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: AppConstants.programsBorderWidth,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: AppPaddings.profileAccountIconLeft,
                    top: AppPaddings.profileAccountIconTop,
                    child: _assetOrIcon(
                      AssetPaths.profileAccountCardIcon,
                      AppConstants.profileAccountIconSize,
                      Icons.credit_card_rounded,
                    ),
                  ),
                  Positioned(
                    left:
                        AppPaddings.profileAccountIconLeft +
                        AppConstants.profileAccountIconSize +
                        AppSpacings.profileAccountIconTitleGap,
                    top: AppPaddings.profileAccountTitleTop,
                    right: AppConstants.profileAccountTextColumnRightInset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.profileAccountTitle,
                          style: AppTextStyles.scheduleCardTitle,
                        ),
                        const SizedBox(
                          height: AppSpacings.profileAccountTitleDescGap,
                        ),
                        SizedBox(
                          width: AppConstants.profileAccountDescMaxWidth,
                          height: AppConstants.profileAccountDescMaxHeight,
                          child: Text(
                            loc.profileAccountDescription,
                            style: AppTextStyles.scheduleCardLabel.copyWith(
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _assetOrIcon(
                        AssetPaths.profileAccountArrow,
                        24,
                        Icons.chevron_right_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _assetOrIcon(String path, double size, IconData fallback) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(fallback, color: Colors.white, size: size),
    );
  }
}

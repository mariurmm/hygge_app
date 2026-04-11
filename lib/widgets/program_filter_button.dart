import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProgramFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ProgramFilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.programsFilterSelected
        : AppColors.programsFilterUnselected;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.programsFilterRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppConstants.programsBlurSigma,
            sigmaY: AppConstants.programsBlurSigma,
          ),
          child: Container(
            width: AppConstants.programsFilterWidth,
            height: AppConstants.programsFilterHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg.withValues(alpha: isSelected ? 0.78 : 0.56),
              borderRadius: BorderRadius.circular(
                AppConstants.programsFilterRadius,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: AppConstants.programsBorderWidth,
              ),
            ),
            child: Text(label, style: AppTextStyles.programsFilter),
          ),
        ),
      ),
    );
  }
}

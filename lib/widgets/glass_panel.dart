import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';

/// Стеклянная панель (blur + полупрозрачный фон) — DRY для настроек и др.
class GlassRoundedPanel extends StatelessWidget {
  const GlassRoundedPanel({
    required this.width,
    required this.child,
    super.key,
    this.height,
    this.borderRadius = AppConstants.settingsGlassRadius,
    this.padding,
  });
  final double width;
  final double? height;
  final double borderRadius;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.programsBlurSigma,
          sigmaY: AppConstants.programsBlurSigma,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.profileAccountCardFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

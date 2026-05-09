import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({
    super.key,
    this.leading,
    this.trailing,
    this.showLogo = true,
    this.title = 'hy.gge concept',
    this.scrollOffset = 0,
  });

  final Widget? leading;
  final Widget? trailing;
  final bool showLogo;
  final String title;
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading;

    final t = (scrollOffset / 120).clamp(0.0, 1.0);

    final blur = lerpDouble(0, 18, t)!;
    final opacity = lerpDouble(0.0, 0.22, t)!;
    final borderOpacity = lerpDouble(0.0, 0.12, t)!;
    final scale = lerpDouble(1.0, 0.96, t)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: AppConstants.appHeaderHeight,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: opacity),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 0.6,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPaddings.programsHeaderHorizontal,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (leadingWidget != null) ...[
                          SizedBox(
                            width: AppConstants.programsHeaderLogoSize,
                            height: AppConstants.programsHeaderLogoSize,
                            child: Center(child: leadingWidget),
                          ),
                        ] else if (showLogo) ...[
                          Hero(
                            tag: 'hygge_logo',
                            child: Image.asset(
                              AssetPaths.hyggeLogo,
                              width: AppConstants.programsHeaderLogoSize,
                              height: AppConstants.programsHeaderLogoSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],

                        const SizedBox(width: 10),

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: 1 - (t * 0.08),
                          child: Text(
                            title,
                            style: AppTextStyles.programsLogo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (trailing != null)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: 1 - (t * 0.1),
                    child: trailing,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  });

  final Widget? leading;
  final Widget? trailing;
  final bool showLogo;
  final String title;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading;

    return SizedBox(
      height: AppConstants.appHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPaddings.programsHeaderHorizontal,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (leadingWidget != null) ...[
                    SizedBox(
                      width: AppConstants.programsHeaderLogoSize,
                      height: AppConstants.programsHeaderLogoSize,
                      child: Center(child: leadingWidget),
                    ),
                  ] else if (showLogo) ...[
                    Image.asset(
                      AssetPaths.hyggeLogo,
                      width: AppConstants.programsHeaderLogoSize,
                      height: AppConstants.programsHeaderLogoSize,
                      fit: BoxFit.contain,
                    ),
                  ],

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      title,
                      style: AppTextStyles.programsLogo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

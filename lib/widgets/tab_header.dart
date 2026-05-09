import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({super.key, this.leading, this.trailing});
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.appHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPaddings.programsHeaderHorizontal,
        ),
        child: Row(
          children: [
            // LEFT SIDE
            Expanded(
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],

                  Image.asset(
                    AssetPaths.hyggeLogo,
                    width: AppConstants.programsHeaderLogoSize,
                    height: AppConstants.programsHeaderLogoSize,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      'hy.gge concept',
                      style: AppTextStyles.programsLogo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE
            ?trailing,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'notification_icon_button.dart';

class ProgramsHeader extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;

  const ProgramsHeader({super.key, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.appHeaderHeight, // 🔥 фиксированная высота
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPaddings.programsHeaderHorizontal,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacings.programsHeaderTitleGap),
                ],
                SvgPicture.asset(
                  AssetPaths.hyggeLogo,
                  width: AppConstants.programsHeaderLogoSize,
                  height: AppConstants.programsHeaderLogoSize,
                ),
                const SizedBox(width: AppSpacings.programsHeaderTitleGap),
                Text('hy.gge concept', style: AppTextStyles.programsLogo),
              ],
            ),

            // правая зона фиксированного размера
            SizedBox(
              width: 48,
              height: 48,
              child: Center(child: trailing ?? const NotificationIconButton()),
            ),
          ],
        ),
      ),
    );
  }
}

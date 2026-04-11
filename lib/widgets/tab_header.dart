import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.programsHeaderHorizontal,
        vertical: AppPaddings.programsHeaderVertical,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AssetPaths.hyggeLogo,
                width: AppConstants.programsHeaderLogoSize,
                height: AppConstants.programsHeaderLogoSize,
              ),
              const SizedBox(width: AppSpacings.programsHeaderTitleGap),
              Text('hy.gge', style: AppTextStyles.programsLogo),
            ],
          ),
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: AppConstants.programsHeaderIconSize,
          ),
        ],
      ),
    );
  }
}
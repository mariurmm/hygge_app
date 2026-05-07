import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class ProfileProgramsHeader extends StatelessWidget {

  const ProfileProgramsHeader({super.key, this.onSettingsTap});
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return ProgramsHeader(
      trailing: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppConstants.profileProgramsHeaderIconSize,
          minHeight: AppConstants.profileProgramsHeaderIconSize,
        ),
        onPressed: onSettingsTap ?? () => context.push(RouteNames.settings),
        icon: Image.asset(
          AssetPaths.settingsIcon,
          width: AppConstants.programsHeaderIconSize,
          height: AppConstants.programsHeaderIconSize,
          errorBuilder: (_, _, _) => const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: AppConstants.programsHeaderIconSize,
          ),
        ),
      ),
    );
  }
}

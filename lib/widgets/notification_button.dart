import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';

Widget notificationIconButton() {
  return Builder(
    builder: (context) => IconButton(
      onPressed: () => context.go('/home/notifications'),
      icon: SvgPicture.asset(
        AssetPaths.notificationIcon,
        width: AppConstants.notificationButtonSize,
        height: AppConstants.notificationButtonSize,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';

class ProfileTravelProgressBar extends StatelessWidget {
  final int percent;

  const ProfileTravelProgressBar({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final p = (percent / 100).clamp(0.0, 1.0);
              final fillW = (c.maxWidth - 5).clamp(0.0, c.maxWidth) * p;
              return Stack(
                children: [
                  Container(
                    width: c.maxWidth,
                    height: AppConstants.scheduleProgressStrokeHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.progressStroke),
                    ),
                  ),
                  Positioned(
                    left: 2.5,
                    top: 2.5,
                    child: Container(
                      width: fillW,
                      height: AppConstants.scheduleProgressFillHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.progressFillStart,
                            AppColors.progressFillEnd,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

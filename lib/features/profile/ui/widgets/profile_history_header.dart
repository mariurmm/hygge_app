import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ProfileHistoryHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const ProfileHistoryHeader({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppConstants.profileHistoryTitleMaxWidth,
          height: AppConstants.profileHistoryTitleMaxHeight,
          child: Text(
            'Недавняя история ваших пройденных программ',
            style: AppTextStyles.scheduleCardTitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppSpacings.profileHistoryTitleLinkGap),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Посмотреть все',
                style: AppTextStyles.scheduleCardLabel.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

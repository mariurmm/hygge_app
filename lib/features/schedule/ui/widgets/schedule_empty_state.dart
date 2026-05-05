import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

final class ScheduleEmptyState extends StatelessWidget {
  final String title;
  final String description;

  const ScheduleEmptyState({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              CupertinoIcons.calendar_badge_minus,
              size: 54,
              color: Colors.white.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.scheduleCalendarTitle.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.scheduleDescription.copyWith(
                color: Colors.white.withValues(alpha: 0.48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

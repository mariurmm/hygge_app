import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class ScheduleCalendar extends StatelessWidget {
  final String monthLabel;
  final List<DateTime?> cells;
  final DateTime today;
  final Set<DateTime> scheduledDates;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ScheduleCalendar({
    super.key,
    required this.monthLabel,
    required this.cells,
    required this.today,
    required this.scheduledDates,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(monthLabel, style: AppTextStyles.scheduleCalendarTitle),
            Row(
              children: [
                IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacings.sm),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final day = cells[index];
            if (day == null) {
              return const SizedBox.shrink();
            }
            final normalizedDay = DateTime(day.year, day.month, day.day);
            final normalizedToday = DateTime(today.year, today.month, today.day);
            final isToday = normalizedDay == normalizedToday;
            final isScheduled = scheduledDates.contains(normalizedDay);

            final bgColor = isToday
                ? Colors.white.withValues(alpha: 0.2)
                : isScheduled
                    ? AppColors.terracotta.withValues(alpha: 0.28)
                    : Colors.transparent;
            final textColor = isToday ? Colors.white : Colors.white.withValues(alpha: 0.9);

            return Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: isToday
                      ? Border.all(color: Colors.white.withValues(alpha: 0.65))
                      : isScheduled
                          ? Border.all(
                              color: AppColors.terracotta.withValues(alpha: 0.9),
                            )
                          : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: AppTextStyles.scheduleDate.copyWith(color: textColor),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

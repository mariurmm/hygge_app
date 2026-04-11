import 'package:flutter/material.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_list.dart';
import 'dart:ui';

class ProgrammCard extends StatelessWidget {
  final ProgrammCardType type;
  final LessonModel lesson;
  const ProgrammCard({super.key, required this.type, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ProgrammCardType.big => ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppConstants.programsBlurSigma,
            sigmaY: AppConstants.programsBlurSigma,
          ),
          child: Container(
            width: AppConstants.programsCardWidth,
            height: AppConstants.programsCardHeight,
            decoration: BoxDecoration(
              color: AppColors.programsCard.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(
                AppConstants.programsCardRadius,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: AppConstants.programsBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: AppConstants.programsCardMediaHeight,
                  decoration: BoxDecoration(
                    color: AppColors.programsCardMedia.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.programsCardRadius),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppPaddings.programsCardHorizontal,
                    AppPaddings.programsCardTop,
                    AppPaddings.programsCardHorizontal,
                    AppPaddings.programsCardBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title.isNotEmpty
                                  ? lesson.title
                                  : 'Утренняя медитация',
                              style: AppTextStyles.programsCardTitle,
                            ),
                          ),
                          Text(
                            _durationLabel(lesson),
                            style: AppTextStyles.programsCardTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacings.programsCardTitleGap),
                      Text(
                        lesson.text.isNotEmpty
                            ? lesson.text
                            : 'Мягкое введение в осознанность, сосредоточение на дыхании и постановке намерений.',
                        style: AppTextStyles.programsCardDescription,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ProgrammCardType.small => Card(
        child: Column(
          children: [
            Text(lesson.title)
          ],
        ),
      ),
    };
  }

  String _durationLabel(LessonModel lesson) {
    final mins = lesson.finishDate.difference(lesson.startDate).inMinutes;
    if (mins > 0) return '$mins мин';
    return '${AppConstants.programsDefaultDurationMin} мин';
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'dart:ui';

class ProgrammCard extends StatelessWidget {
  final ProgrammCardType type;
  final LessonModel lesson;

  /// Подпись поверх превью (история / недавний сеанс), например «Вчера 8:00».
  final String? timingOverlayLabel;

  const ProgrammCard({
    super.key,
    required this.type,
    required this.lesson,
    this.timingOverlayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.programsCardRadius),
                  ),
                  child: SizedBox(
                    height: AppConstants.programsCardMediaHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                AppColors.programsCardMedia.withValues(alpha: 0.95),
                          ),
                        ),
                        if (timingOverlayLabel != null) ...[
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: AppPaddings.profileRecentSessionTimeLeft,
                            top: AppPaddings.profileRecentSessionTimeTop,
                            child: Text(
                              timingOverlayLabel!,
                              style: AppTextStyles.scheduleCardLabel,
                            ),
                          ),
                        ],
                      ],
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
                                  : loc.programCardDefaultTitle,
                              style: AppTextStyles.programsCardTitle,
                            ),
                          ),
                          Text(
                            _durationLabel(lesson, loc),
                            style: AppTextStyles.programsCardTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacings.programsCardTitleGap),
                      Text(
                        lesson.text.isNotEmpty
                            ? lesson.text
                            : loc.programCardDefaultDescription,
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

  String _durationLabel(LessonModel lesson, AppLocalizations loc) {
    final mins = lesson.finishDate.difference(lesson.startDate).inMinutes;
    if (mins > 0) return loc.minutesLabel(mins);
    return loc.minutesLabel(AppConstants.programsDefaultDurationMin);
  }
}

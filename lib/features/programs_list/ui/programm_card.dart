import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/features/favourites/ui/widgets/favourite_button.dart';
import 'package:hygge_app/features/programs_detail/ui/program_details_page.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProgrammCard extends StatelessWidget {
  final ProgrammCardType type;
  final ProgramModel program;
  final LessonModel? lesson;
  final MasterModel? master;
  final String? timingOverlayLabel;

  const ProgrammCard({
    super.key,
    required this.type,
    required this.program,
    this.lesson,
    this.master,
    this.timingOverlayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _openDetails(context),
      child: switch (type) {
        ProgrammCardType.big => _BigProgramCard(
          program: program,
          lesson: lesson,
          timingOverlayLabel: timingOverlayLabel,
          loc: loc,
        ),
        ProgrammCardType.small => _SmallProgramCard(
          program: program,
          lesson: lesson,
          loc: loc,
        ),
      },
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgramDetailsPage(
          program: program,
          lesson: lesson ?? LessonModel.empty,
          master: master ?? MasterModel.empty,
        ),
      ),
    );
  }
}

class _BigProgramCard extends StatelessWidget {
  final ProgramModel program;
  final LessonModel? lesson;
  final String? timingOverlayLabel;
  final AppLocalizations loc;

  const _BigProgramCard({
    required this.program,
    required this.lesson,
    required this.timingOverlayLabel,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
              _ProgramMedia(
                program: program,
                timingOverlayLabel: timingOverlayLabel,
              ),
              Expanded(
                child: Padding(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              program.title.isNotEmpty
                                  ? program.title
                                  : loc.programCardDefaultTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.programsCardTitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 0,
                            child: Text(
                              _durationLabel(lesson, loc),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.programsCardTitle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacings.programsCardTitleGap),
                      Expanded(
                        child: Text(
                          program.text.isNotEmpty
                              ? program.text
                              : loc.programCardDefaultDescription,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.programsCardDescription,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallProgramCard extends StatelessWidget {
  final ProgramModel program;
  final LessonModel? lesson;
  final AppLocalizations loc;

  const _SmallProgramCard({
    required this.program,
    required this.lesson,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.programsBlurSigma,
          sigmaY: AppConstants.programsBlurSigma,
        ),
        child: Container(
          width: 150,
          height: 170,
          decoration: BoxDecoration(
            color: AppColors.programsCard.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SmallProgramMedia(program: program),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title.isNotEmpty
                          ? program.title
                          : loc.programCardDefaultTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.programsCardTitle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _durationLabel(lesson, loc),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.programsCardDescription,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramMedia extends StatelessWidget {
  final ProgramModel program;
  final String? timingOverlayLabel;

  const _ProgramMedia({
    required this.program,
    required this.timingOverlayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.programsCardRadius),
      ),
      child: SizedBox(
        height: AppConstants.programsCardMediaHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ProgramImage(imageUrl: program.imageUrl),
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
            Positioned(
              right: 14,
              top: 14,
              child: FavouriteButton(programId: program.uuid),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallProgramMedia extends StatelessWidget {
  final ProgramModel program;

  const _SmallProgramMedia({required this.program});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: _ProgramImage(imageUrl: program.imageUrl),
      ),
    );
  }
}

class _ProgramImage extends StatelessWidget {
  final String imageUrl;

  const _ProgramImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _ProgramImageFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ProgramImageFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return _ProgramImageFallback();
      },
    );
  }
}

class _ProgramImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.programsCardMedia.withValues(alpha: 0.95),
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 28),
      ),
    );
  }
}

String _durationLabel(LessonModel? lesson, AppLocalizations loc) {
  if (lesson == null || lesson.isEmpty) {
    return loc.minutesLabel(AppConstants.programsDefaultDurationMin);
  }

  final int mins = lesson.finishDate.difference(lesson.startDate).inMinutes;

  if (mins > 0) return loc.minutesLabel(mins);

  return loc.minutesLabel(AppConstants.programsDefaultDurationMin);
}

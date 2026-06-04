import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_category.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/favourites/ui/widgets/favourite_button.dart';
import 'package:hygge_app/features/programs_detail/ui/program_details_page.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class ProgrammCard extends StatelessWidget {
  const ProgrammCard({
    required this.type,
    required this.program,
    super.key,
    this.lesson,
    this.master,
    this.timingOverlayLabel,
  });

  final ProgrammCardType type;
  final ProgramModel program;
  final LessonModel? lesson;
  final MasterModel? master;
  final String? timingOverlayLabel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
    final bookingBloc = context.read<BookingBloc>(); // ← capture before push

    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => BlocProvider.value(
            value: bookingBloc, // ← pass it in
            child: ProgramDetailsPage(
              program: program,
              lesson: lesson ?? LessonModel.empty,
              master: master ?? MasterModel.empty,
            ),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      ),
    );
  }
}

class _BigProgramCard extends StatelessWidget {
  const _BigProgramCard({
    required this.program,
    required this.lesson,
    required this.timingOverlayLabel,
    required this.loc,
  });

  final ProgramModel program;
  final LessonModel? lesson;
  final String? timingOverlayLabel;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
      child: Container(
        width: AppConstants.programsCardWidth,
        decoration: BoxDecoration(
          color: AppColors.programsCard.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(AppConstants.programsCardRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ProgramMedia(
              program: program,
              timingOverlayLabel: timingOverlayLabel,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppPaddings.programsCardHorizontal,
                13,
                AppPaddings.programsCardHorizontal,
                15,
              ),
              child: _BigProgramBody(
                title: _title(program, loc),
                category: _categoryLabel(program, loc),
                time: _timeLabel(lesson, loc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallProgramCard extends StatelessWidget {
  const _SmallProgramCard({
    required this.program,
    required this.lesson,
    required this.loc,
  });

  final ProgramModel program;
  final LessonModel? lesson;
  final AppLocalizations loc;

  static const double _width = 164;
  static const double _radius = 22;
  static const double _mediaHeight = 82;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppConstants.programsBlurSigma,
            sigmaY: AppConstants.programsBlurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.programsCard.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SmallProgramMedia(
                  program: program,
                  height: _mediaHeight,
                  radius: _radius,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
                    child: _SmallProgramBody(
                      title: _title(program, loc),
                      date: _dateLabel(lesson),
                      time: _timeLabel(lesson, loc),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigProgramBody extends StatelessWidget {
  const _BigProgramBody({
    required this.title,
    required this.category,
    required this.time,
  });

  final String title;
  final String category;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.programsCardTitle.copyWith(
                  height: 1.18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: AppTextStyles.programsCardDescription.copyWith(
                  height: 1.18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.programsCardDescription.copyWith(
            fontSize: 13,
            height: 1.15,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _SmallProgramBody extends StatelessWidget {
  const _SmallProgramBody({
    required this.title,
    required this.date,
    required this.time,
  });

  final String title;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final hasDate = date.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.programsCardTitle.copyWith(
            fontSize: 15,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 10),

        if (hasDate) ...<Widget>[
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.programsCardDescription.copyWith(
              fontSize: 13,
              height: 1.1,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 2),
        ],

        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.programsCardDescription.copyWith(
            fontSize: 14,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ProgramMedia extends StatelessWidget {
  const _ProgramMedia({
    required this.program,
    required this.timingOverlayLabel,
  });

  final ProgramModel program;
  final String? timingOverlayLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.programsCardRadius),
      ),
      child: SizedBox(
        height: AppConstants.programsCardMediaHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProgramImage(imageUrl: program.imageUrl),
            if (timingOverlayLabel != null) ...<Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
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
              child: FavouriteButton(programId: program.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallProgramMedia extends StatelessWidget {
  const _SmallProgramMedia({
    required this.program,
    required this.height,
    required this.radius,
  });

  final ProgramModel program;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radius),
        ),
        child: _ProgramImage(imageUrl: program.imageUrl),
      ),
    );
  }
}

class _ProgramImage extends StatelessWidget {
  const _ProgramImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    if (url.isEmpty) {
      return const _ProgramImageFallback();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ProgramImageFallback(),
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const _ProgramImageFallback();
      },
    );
  }
}

class _ProgramImageFallback extends StatelessWidget {
  const _ProgramImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.programsCardMedia.withValues(alpha: 0.95),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}

String _title(ProgramModel program, AppLocalizations loc) {
  if (program.title.isNotEmpty) return program.title;

  return loc.programCardDefaultTitle;
}

String _timeLabel(LessonModel? lesson, AppLocalizations loc) {
  if (lesson == null || lesson.isEmpty) {
    return loc.minutesLabel(AppConstants.programsDefaultDurationMin);
  }

  return lesson.scheduleTimeRange();
}

String _dateLabel(LessonModel? lesson) {
  if (lesson == null || lesson.isEmpty) {
    return '';
  }

  final locale = Intl.getCurrentLocale();

  return DateFormat('d MMMM', locale).format(lesson.startDate);
}

String _categoryLabel(ProgramModel program, AppLocalizations loc) {
  return switch (program.category) {
    ProgramCategory.meditation => loc.filterMeditation,
    ProgramCategory.yoga => loc.filterYoga,
    ProgramCategory.outdoor => loc.filterOutdoor,
    ProgramCategory.ceremony => loc.filterCeremony,
    ProgramCategory.masterClass => loc.filterMasterClass,
    ProgramCategory.lecture => loc.filterLecture,
    ProgramCategory.authorTour => loc.filterAuthorTour,
  };
}

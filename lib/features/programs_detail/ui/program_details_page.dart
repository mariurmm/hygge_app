import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/favourites_repository.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/masters/ui/master_details_page.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_bloc.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_event.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_state.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/base_layout.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'package:intl/intl.dart';

class ProgramDetailsPage extends StatelessWidget {
  const ProgramDetailsPage({
    required this.program,
    required this.lesson,
    required this.master,
    super.key,
  });

  final ProgramModel program;
  final LessonModel lesson;
  final MasterModel master;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgramDetailsBloc>(
      create: (context) =>
          ProgramDetailsBloc(
            favouritesRepository: context.read<FavouritesRepository>(),
            programsRepository: context.read<ProgramsRepository>(),
            bookingRepository: context.read<BookingRepository>(),
            userId: context.read<AppBloc>().state.user.uid,
          )..add(
            ProgramDetailsStarted(
              program: program,
              lesson: lesson,
              master: master,
            ),
          ),
      child: const ProgramDetailsView(),
    );
  }
}

class ProgramDetailsView extends StatelessWidget {
  const ProgramDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = _localeTag(context);

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state.status == BookingUiStatus.cancelConfirmationRequired) {
          final bookingId = state.existingBooking?.id;
          if (bookingId == null) return;
          final programTitle =
              context.read<ProgramDetailsBloc>().state.program.title;
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => _ProgramCancelDialog(programTitle: programTitle),
          );
          if ((confirmed ?? false) && context.mounted) {
            context.read<BookingBloc>().add(
              BookingConfirmCancelEvent(bookingId: bookingId),
            );
          }
          return;
        }

        const snackbarStatuses = {
          BookingUiStatus.success,
          BookingUiStatus.cancelled,
          BookingUiStatus.error,
          BookingUiStatus.noSubscription,
        };
        if (!snackbarStatuses.contains(state.status)) return;
        final loc = AppLocalizations.of(context);
        final msg = switch (state.status) {
          BookingUiStatus.success => loc.bookingSuccess(
            context.read<ProgramDetailsBloc>().state.program.title,
          ),
          BookingUiStatus.cancelled => loc.bookingCancelled,
          BookingUiStatus.noSubscription => loc.bookingNoSubscription,
          BookingUiStatus.error => loc.bookingError(state.errorMessage ?? ''),
          _ => null,
        };
        if (msg == null) return;
        final isPositive = state.status == BookingUiStatus.success ||
            state.status == BookingUiStatus.cancelled;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: isPositive
                ? AppColors.primary
                : AppColors.darkBrown,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: BlocBuilder<ProgramDetailsBloc, ProgramDetailsState>(
          builder: (context, state) {
            final program = state.program;
            final selectedLesson = state.lesson;
            final master = state.master;
            final isBooked = state.isSelectedLessonBooked;

            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset(
                      AssetPaths.homeBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: SafeArea(
                      bottom: false,
                      child: HyggeScreenLayout(
                        header: ProgramsHeader(
                          trailing: const SizedBox.shrink(),
                          leading: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth:
                                  AppConstants.profileProgramsHeaderIconSize,
                              minHeight:
                                  AppConstants.profileProgramsHeaderIconSize,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Image.asset(
                              AssetPaths.arrowBack,
                              width: AppConstants.arrowBackIconSize,
                              height: AppConstants.arrowBackIconSize,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPaddings.profileScreenHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 24),
                                _ProgramTitleBlock(program: program),
                                const SizedBox(
                                  height: AppSpacings.profileNameCardGap,
                                ),
                                _SectionTitle(
                                  text: loc.programDescription,
                                ),
                                const SizedBox(height: 12),
                                _GlassBlock(
                                  child: Text(
                                    program.text,
                                    softWrap: true,
                                    style: AppTextStyles.programsCardDescription
                                        .copyWith(height: 1.36),
                                  ),
                                ),
                                const SizedBox(
                                  height: AppSpacings.profileCardsVerticalGap,
                                ),
                                _SectionTitle(text: loc.programMaster),
                                const SizedBox(height: 12),
                                _MasterCard(master: master),
                                const SizedBox(
                                  height: AppSpacings.profileCardsVerticalGap,
                                ),
                                _SectionTitle(text: loc.programDates),
                                const SizedBox(height: 8),
                                Text(
                                  loc.programChooseDate,
                                  style: AppTextStyles.programsCardDescription,
                                ),
                                const SizedBox(height: 12),
                                _LessonDatesPanel(
                                  lessons: state.availableLessons,
                                  selectedLesson: selectedLesson,
                                  bookedLessonIds: state.bookedLessonIds,
                                  programPrice: program.price,
                                  locale: locale,
                                  emptyText: loc.programNoDates,
                                  alreadyBookedText: loc.programAlreadyBooked,
                                ),
                                const SizedBox(
                                  height: AppSpacings.profileCardsVerticalGap,
                                ),
                                _BottomActions(
                                  program: program,
                                  selectedLesson: selectedLesson,
                                  isBooked: isBooked,
                                  isFavourite: state.isFavourite,
                                  bookText: loc.programBook,
                                  alreadyBookedText: loc.programAlreadyBooked,
                                  comingSoonText: loc.comingSoon,
                                ),
                                const SizedBox(
                                  height: AppConstants.profileCardsBottomInset,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgramTitleBlock extends StatelessWidget {
  const _ProgramTitleBlock({
    required this.program,
  });

  final ProgramModel program;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          program.title,
          softWrap: true,
          style: AppTextStyles.programsHeading,
        ),
        if (program.ritual.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            program.ritual,
            softWrap: true,
            style: AppTextStyles.programsSubtitle,
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.programsHeading.copyWith(fontSize: 22),
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({
    required this.master,
  });

  final MasterModel master;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: master.isEmpty
            ? null
            : () async {
                await openMasterDetails(context, master: master);
              },
        borderRadius: BorderRadius.circular(26),
        child: _GlassBlock(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.programsCardMedia,
                backgroundImage: master.photoUrl.isNotEmpty
                    ? NetworkImage(master.photoUrl)
                    : null,
                child: master.photoUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      master.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.programsCardTitle,
                    ),
                    if (master.bio.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        master.bio,
                        softWrap: true,
                        style: AppTextStyles.programsCardDescription.copyWith(
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonDatesPanel extends StatelessWidget {
  const _LessonDatesPanel({
    required this.lessons,
    required this.selectedLesson,
    required this.bookedLessonIds,
    required this.programPrice,
    required this.emptyText,
    required this.alreadyBookedText,
    required this.locale,
  });

  final List<LessonModel> lessons;
  final LessonModel selectedLesson;
  final Set<String> bookedLessonIds;
  final double programPrice;
  final String emptyText;
  final String alreadyBookedText;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return _GlassBlock(
        child: Text(
          emptyText,
          softWrap: true,
          style: AppTextStyles.programsCardDescription,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: lessons
          .map((lesson) {
            final isSelected = lesson.id == selectedLesson.id;
            final isBooked = bookedLessonIds.contains(lesson.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LessonDateCard(
                lesson: lesson,
                locale: locale,
                price: programPrice,
                isSelected: isSelected,
                isBooked: isBooked,
                alreadyBookedText: alreadyBookedText,
                onTap: () {
                  context.read<ProgramDetailsBloc>().add(
                    ProgramDetailsLessonSelected(lesson),
                  );
                },
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _LessonDateCard extends StatelessWidget {
  const _LessonDateCard({
    required this.lesson,
    required this.locale,
    required this.price,
    required this.isSelected,
    required this.isBooked,
    required this.alreadyBookedText,
    required this.onTap,
  });

  final LessonModel lesson;
  final String locale;
  final double price;
  final bool isSelected;
  final bool isBooked;
  final String alreadyBookedText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMMM, EEEE', locale).format(lesson.startDate);
    final time = lesson.scheduleTimeRange(locale: locale);
    final formattedPrice = _formatPrice(price);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: _GlassBlock(
          padding: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : AppColors.profileAccountCardFill.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.18),
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        date,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.scheduleCardTitle.copyWith(
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.scheduleCardTitle.copyWith(
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.scheduleCardLabel.copyWith(
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                if (isBooked) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    alreadyBookedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.scheduleCardLabel.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.program,
    required this.selectedLesson,
    required this.isBooked,
    required this.isFavourite,
    required this.bookText,
    required this.alreadyBookedText,
    required this.comingSoonText,
  });

  final ProgramModel program;
  final LessonModel selectedLesson;
  final bool isBooked;
  final bool isFavourite;
  final String bookText;
  final String alreadyBookedText;
  final String comingSoonText;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: program.isBookable
              ? BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, bookingState) {
                    final isLoading =
                        bookingState.status == BookingUiStatus.loading;

                    final bookButton = SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ||
                                isBooked ||
                                selectedLesson.isEmpty ||
                                selectedLesson.isFull
                            ? null
                            : () => context.read<BookingBloc>().add(
                                BookingBookLessonEvent(
                                  lesson: selectedLesson,
                                  programTitle: program.title,
                                  whatsAppMessage: loc.whatsAppNoSubscription(
                                    program.title,
                                  ),
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.55,
                          ),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isBooked
                                    ? alreadyBookedText
                                    : selectedLesson.isFull
                                        ? loc.noSpots
                                        : bookText,
                                style: AppTextStyles.button,
                              ),
                      ),
                    );

                    if (!isBooked) return bookButton;

                    final canCancel = selectedLesson.startDate
                            .difference(DateTime.now()) >
                        const Duration(hours: 24);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        bookButton,
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: (canCancel && !isLoading)
                                ? () => context.read<BookingBloc>().add(
                                    const BookingRequestCancelEvent(),
                                  )
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.terracotta,
                              disabledForegroundColor:
                                  AppColors.terracotta.withValues(alpha: 0.4),
                              side: BorderSide(
                                color: AppColors.terracotta.withValues(
                                  alpha: canCancel ? 0.6 : 0.25,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              canCancel
                                  ? loc.cancelBooking
                                  : loc.cancelTooLate,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.terracotta.withValues(
                                  alpha: canCancel ? 1.0 : 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : SizedBox(
                  height: 54,
                  child: _DisabledButton(text: comingSoonText),
                ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 54,
          width: 54,
          child: _FavouriteButton(
            isFavourite: isFavourite,
            onTap: () => context.read<ProgramDetailsBloc>().add(
              ProgramDetailsFavouriteToggled(program),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramCancelDialog extends StatelessWidget {
  const _ProgramCancelDialog({required this.programTitle});

  final String programTitle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AppColors.darkBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        loc.cancelDialogTitle,
        style: AppTextStyles.scheduleCalendarTitle,
      ),
      content: Text(
        loc.cancelDialogContent(programTitle),
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            loc.cancelDialogBack,
            style: AppTextStyles.button.copyWith(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            loc.cancelDialogConfirm,
            style: AppTextStyles.button.copyWith(color: AppColors.terracotta),
          ),
        ),
      ],
    );
  }
}

class _GlassBlock extends StatelessWidget {
  const _GlassBlock({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.profileAccountCardFill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: AppTextStyles.button.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  const _FavouriteButton({
    required this.isFavourite,
    required this.onTap,
  });

  final bool isFavourite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.profileAccountCardFill,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _localeTag(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;

  return switch (code) {
    'en' => 'en',
    'kk' => 'kk',
    _ => 'ru',
  };
}

String _formatPrice(double price) {
  if (price <= 0) return '—';

  final formatter = NumberFormat.decimalPattern('ru');
  return '${formatter.format(price)} ₸';
}

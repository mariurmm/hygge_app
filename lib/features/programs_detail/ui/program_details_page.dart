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
import 'package:hygge_app/data/repositories/favourites_repository/favourites_repository_impl.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository/upcoming_lesson_repository_impl.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/glass_panel.dart';

import '../bloc/program_details_bloc.dart';
import '../bloc/program_details_event.dart';
import '../bloc/program_details_state.dart';

class ProgramDetailsPage extends StatelessWidget {
  final LessonModel program;

  const ProgramDetailsPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProgramDetailsBloc(
            favouritesRepository: FavouritesRepositoryImpl(),
            bookingRepository: UpcomingLessonRepositoryImpl(),
          )..add(ProgramDetailsStarted(program)),
      child: const ProgramDetailsView(),
    );
  }
}

class ProgramDetailsView extends StatelessWidget {
  const ProgramDetailsView({super.key});

  String _locale(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'en' || code == 'ru' || code == 'kk') return code;
    return 'ru';
  }

  String _t(BuildContext context, String key) {
    final locale = _locale(context);

    const values = {
      'ru': {
        'description': 'Описание программы',
        'master': 'Мастер',
        'price': 'Стоимость',
        'time': 'Время',
        'date': 'Дата',
        'book': 'Записаться',
        'booking': 'Запись...',
      },
      'en': {
        'description': 'Program description',
        'master': 'Master',
        'price': 'Price',
        'time': 'Time',
        'date': 'Date',
        'book': 'Book',
        'booking': 'Booking...',
      },
      'kk': {
        'description': 'Бағдарлама сипаттамасы',
        'master': 'Шебер',
        'price': 'Бағасы',
        'time': 'Уақыты',
        'date': 'Күні',
        'book': 'Жазылу',
        'booking': 'Жазылуда...',
      },
    };

    return values[locale]?[key] ?? values['ru']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: BlocBuilder<ProgramDetailsBloc, ProgramDetailsState>(
        builder: (context, state) {
          final program = state.program;
          final master = program.master;

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBody: true,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.profileCardsBottomInset,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPaddings.profileScreenHorizontal,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InnerHeader(
                            onBack: () => Navigator.of(context).pop(),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            program.title,
                            style: AppTextStyles.programsHeading,
                          ),

                          if (program.ritual.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              program.ritual,
                              style: AppTextStyles.programsSubtitle,
                            ),
                          ],

                          const SizedBox(
                            height: AppSpacings.profileNameCardGap,
                          ),

                          _GlassCard(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _InfoRow(
                                  label: _t(context, 'price'),
                                  value:
                                      '${program.price.toStringAsFixed(0)} ₸',
                                ),
                                _InfoRow(
                                  label: _t(context, 'time'),
                                  value: program.scheduleTimeRange(),
                                ),
                                _InfoRow(
                                  label: _t(context, 'date'),
                                  value: program.scheduleDayLabel(
                                    DateTime.now(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: AppSpacings.profileCardsVerticalGap,
                          ),

                          Text(
                            _t(context, 'description'),
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 22,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _GlassCard(
                            height: 170,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                program.text,
                                style: AppTextStyles.programsCardDescription,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: AppSpacings.profileCardsVerticalGap,
                          ),

                          Text(
                            _t(context, 'master'),
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 22,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _MasterGlassCard(
                            name: '${master.firstName} ${master.lastName}',
                            bio: master.bio,
                            avatarUrl: master.avatarUrl,
                          ),

                          const SizedBox(
                            height: AppSpacings.profileCardsVerticalGap,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: program.isBookable
                                      ? ElevatedButton(
                                          onPressed: state.isBooking
                                              ? null
                                              : () {
                                                  context
                                                      .read<
                                                        ProgramDetailsBloc
                                                      >()
                                                      .add(
                                                        ProgramDetailsBooked(
                                                          program,
                                                        ),
                                                      );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: AppColors
                                                .primary
                                                .withValues(alpha: 0.55),
                                            disabledForegroundColor: Colors
                                                .white
                                                .withValues(alpha: 0.75),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: Text(
                                            state.isBooking
                                                ? _t(context, 'booking')
                                                : _t(context, 'book'),
                                            style: AppTextStyles.button,
                                          ),
                                        )
                                      : Container(
                                          height: 54,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .profileAccountCardFill,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context).comingSoon,
                                            style: AppTextStyles.button
                                                .copyWith(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 54,
                                width: 54,
                                child: _FavouriteButton(
                                  isFavourite: state.isFavourite,
                                  onTap: () {
                                    context.read<ProgramDetailsBloc>().add(
                                      ProgramDetailsFavouriteToggled(program),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InnerHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _InnerHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: onBack,
            icon: Image.asset(
              AssetPaths.arrowBackPng,
              width: AppConstants.programsHeaderIconSize,
              height: AppConstants.programsHeaderIconSize,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: AppConstants.programsHeaderIconSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'hygge concept',
            style: AppTextStyles.programsLogo.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final double height;
  final Widget child;

  const _GlassCard({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassRoundedPanel(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.settingsLabel16Light),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.settingsInput16Medium,
          ),
        ),
      ],
    );
  }
}

class _MasterGlassCard extends StatelessWidget {
  final String name;
  final String bio;
  final String avatarUrl;

  const _MasterGlassCard({
    required this.name,
    required this.bio,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassRoundedPanel(
      width: double.infinity,
      height: 124,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.programsCardMedia,
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.programsCardTitle),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.programsCardDescription.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onTap;

  const _FavouriteButton({required this.isFavourite, required this.onTap});

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

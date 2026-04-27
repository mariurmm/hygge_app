import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_cubit.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProfileFavouritesSection extends StatelessWidget {
  const ProfileFavouritesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocSelector<FavouritesCubit, FavouritesState, List<LessonModel>>(
      selector: (state) => state.favouriteLessons,
      builder: (context, lessons) {
        if (lessons.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacings.profileHistorySectionTop),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPaddings.profileScreenHorizontal,
              ),
              child: Text(
                loc.profileFavouritesSectionTitle,
                style: AppTextStyles.programsHeading.copyWith(fontSize: 24),
              ),
            ),

            const SizedBox(height: AppSpacings.profileHistoryLinkCardGap),

            SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPaddings.profileScreenHorizontal,
                ),
                itemCount: lessons.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacings.programsCardsGap),
                itemBuilder: (context, index) {
                  return ProgrammCard(
                    type: ProgrammCardType.small,
                    lesson: lessons[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

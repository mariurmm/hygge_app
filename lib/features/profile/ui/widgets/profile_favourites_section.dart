// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hygge_app/core/constants/app_constants.dart';
// import 'package:hygge_app/core/constants/app_spacings.dart';
// import 'package:hygge_app/core/theme/app_text_styles.dart';
// import 'package:hygge_app/data/models/lesson_model.dart';
// import 'package:hygge_app/features/favourites/bloc/favourites_cubit.dart';
// import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';
// import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
// import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
// import 'package:hygge_app/l10n/generated/app_localizations.dart';

// class ProfileFavouritesSection extends StatelessWidget {
//   const ProfileFavouritesSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return BlocSelector<FavouritesCubit, FavouritesState, List<LessonModel>>(
//       selector: (state) => state.favouriteLessons,
//       builder: (context, lessons) {
//         if (lessons.isEmpty) return const SizedBox.shrink();

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: AppSpacings.profileHistorySectionTop),
//             Text(
//               loc.profileFavouritesSectionTitle,
//               style: AppTextStyles.programsHeading,
//             ),
//             SizedBox(height: AppSpacings.profileHistoryLinkCardGap),
//             SizedBox(
//               height: AppConstants.programsCardHeight,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: lessons.length,
//                 separatorBuilder: (_, __) =>
//                     const SizedBox(width: AppSpacings.programsCardsGap),
//                 itemBuilder: (context, index) => ProgrammCard(
//                   type: ProgrammCardType.big,
//                   lesson: lessons[index],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
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
    print('PROFILE FAV SECTION BUILD');

    final loc = AppLocalizations.of(context);

    return BlocSelector<FavouritesCubit, FavouritesState, List<LessonModel>>(
      selector: (state) {
        print('SELECTOR RUN');
        return state.favouriteLessons;
      },
      builder: (context, lessons) {
        print('FAV BUILDER: ${lessons.length}');

        if (lessons.isEmpty) {
          print('FAV EMPTY → HIDDEN');
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacings.profileHistorySectionTop),

            Text(
              loc.profileFavouritesSectionTitle,
              style: AppTextStyles.programsHeading,
            ),

            SizedBox(height: AppSpacings.profileHistoryLinkCardGap),

            SizedBox(
              height: AppConstants.programsCardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lessons.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacings.programsCardsGap),
                itemBuilder: (context, index) {
                  print('RENDER CARD ${lessons[index].uuid}');
                  return ProgrammCard(
                    type: ProgrammCardType.big,
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

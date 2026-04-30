import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/programs/bloc/programs_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/program_filter_button.dart';
import '../../../widgets/tab_header.dart';
import '../../programs_list/ui/programm_list.dart';

class ProgramsTab extends StatelessWidget {
  const ProgramsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgramsBloc>(
      create: (_) => ProgramsBloc(),
      child: BlocListener<ProgramsBloc, ProgramsState>(
        listenWhen: (previous, current) =>
            previous.allLessons != current.allLessons,
        listener: (context, state) {
          context.read<FavouritesBloc>().add(
            FavouritesLessonsRegistered(state.allLessons),
          );
        },
        child: BlocBuilder<ProgramsBloc, ProgramsState>(
          builder: (context, state) {
            final AppLocalizations loc = AppLocalizations.of(context);

            final List<String> filterLabels = <String>[
              loc.filterAll,
              loc.filterMeditation,
              loc.filterYoga,
              loc.filterOutdoor,
              loc.filterCeremony,
              loc.filterMasterClass,
              loc.filterLecture,
              loc.filterAuthorTour,
            ];

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
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const ProgramsHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.programsCardsBottomInset,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppPaddings.programsScreenHorizontal,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        loc.programsHeading,
                                        style: AppTextStyles.programsHeading,
                                      ),
                                      const SizedBox(
                                        height: AppSpacings.programsLeadGap,
                                      ),
                                      Text(
                                        loc.programsDescription,
                                        style: AppTextStyles.programsSubtitle,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: AppSpacings.programsBodyGap,
                                ),

                                SizedBox(
                                  height: AppConstants.programsFilterHeight,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          AppPaddings.programsScreenHorizontal,
                                    ),
                                    itemCount: filterLabels.length,
                                    separatorBuilder: (_, __) => const SizedBox(
                                      width: AppSpacings.programsFiltersGap,
                                    ),
                                    itemBuilder: (context, index) {
                                      return ProgramFilterButton(
                                        label: filterLabels[index],
                                        isSelected:
                                            state.selectedFilter.index == index,
                                        isAllPrograms: index == 0,
                                        onTap: () {
                                          context
                                              .read<ProgramsBloc>()
                                              .selectFilter(index);
                                        },
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  height: AppSpacings.programsFiltersGap,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppPaddings.programsScreenHorizontal,
                                  ),
                                  child: ProgrammList(
                                    type: ProgrammCardType.big,
                                    lessons: state.visibleLessons,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

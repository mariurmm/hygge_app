import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/repositories/programs_repository/programs_repository.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_bloc.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/program_filter_button.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class ProgramsTab extends StatelessWidget {
  const ProgramsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgramsBloc>(
      create: (ctx) =>
          ProgramsBloc(repository: ctx.read<ProgramsRepository>())
            ..add(const ProgramsInitialized()),
      child: BlocListener<ProgramsBloc, ProgramsState>(
        listenWhen: (previous, current) =>
            previous.allPrograms != current.allPrograms,
        listener: (context, state) {
          context.read<FavouritesBloc>().add(
            FavouritesLessonsRegistered(state.allPrograms),
          );
        },
        child: BlocBuilder<ProgramsBloc, ProgramsState>(
          builder: (context, state) {
            final loc = AppLocalizations.of(context);

            final filterLabels = [
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
                                          context.read<ProgramsBloc>().add(
                                            ProgramsFilterChanged(index),
                                          );
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
                                    programs: state.visiblePrograms,
                                    lessonsByProgramId:
                                        state.nearestLessonsByProgramId,
                                    mastersById: state.mastersById,
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

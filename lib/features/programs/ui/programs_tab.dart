import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/programs/bloc/programs_bloc.dart';
import '../../../features/programs/bloc/programs_state.dart';
import '../../../widgets/program_filter_button.dart';
import '../../../features/programs_list/presentation/ui/programm_list.dart';
import '../../../widgets/tab_header.dart';

class ProgramsTab extends StatelessWidget {
  const ProgramsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramsBloc(),
      child: BlocBuilder<ProgramsBloc, ProgramsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AssetPaths.homeBackground,
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProgramsHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.programsCardsBottomInset,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPaddings.programsScreenHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Организованные мастерами программы',
                                  style: AppTextStyles.programsHeading,
                                ),
                                const SizedBox(
                                  height: AppSpacings.programsLeadGap,
                                ),
                                Text(
                                  'Откройте для себя ритмические практики, призванные восстановить ваше естественное состояние. Расслабьтесь, дышите и найдите свое убежище.',
                                  style: AppTextStyles.programsSubtitle,
                                ),
                                const SizedBox(
                                  height: AppSpacings.programsBodyGap,
                                ),
                                SizedBox(
                                  height: AppConstants.programsFilterHeight,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.filters.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(
                                          width: AppSpacings.programsFiltersGap,
                                        ),
                                    itemBuilder: (context, index) {
                                      return ProgramFilterButton(
                                        label: state.filters[index],
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
                                ProgrammList(
                                  type: ProgrammCardType.big,
                                  lessons: state.visibleLessons,
                                ),
                              ],
                            ),
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
    );
  }
}

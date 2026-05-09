import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/features/profile/bloc/profile_state.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_about_section.dart';
import 'package:hygge_app/features/profile/ui/widgets/profile_history_header.dart';
import 'package:hygge_app/features/programs_list/ui/programm_card.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProfileHistorySection extends StatelessWidget {

  const ProfileHistorySection({
    required this.now, 
    required this.state, 
    required this.loc, 
    super.key,});
  final ProfileState state;
  final AppLocalizations loc;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.profileScreenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          ProfileHistoryHeader(
            onViewAll: () =>context.push(RouteNames.history),
          ),
          const SizedBox( 
            height: AppSpacings.profileHistoryLinkCardGap,
          ),
          if (state.isHistoryLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, ),
            child: Center(
              child: CircularProgressIndicator( 
                color: Colors.white,
              ),
            ),
          )
          else if (state.recentSessionProgram != null)
          ProgrammCard(
            type: ProgrammCardType.big, 
            program: state.recentSessionProgram!, 
            lesson: state.recentSessionLesson,
            master: state.recentSessionMaster,
            timingOverlayLabel: state.recentSessionLesson
                ?.historyWhenLabel(now),
          ),
          const SizedBox( 
            height: AppSpacings.profileCardsVerticalGap,
          ),
          const ProfileAboutSection(),
        ],
      ),
    );
  }
}

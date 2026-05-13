import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_bloc.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramsBloc, ProgramsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).tabPrograms),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ProgrammList(
              type: ProgrammCardType.big,
              programs: state.visiblePrograms,
              lessonsByProgramId: state.nearestLessonsByProgramId,
              mastersById: state.mastersById,
            ),
          ),
        );
      },
    );
  }
}

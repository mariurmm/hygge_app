import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/programs_list/presentation/bloc/programms_bloc.dart';
import 'package:hygge_app/features/programs_list/presentation/ui/programm_card.dart';
import 'package:hygge_app/ui_kit/app_loading_indicator.dart';

enum ProgrammCardType { small, big }

class ProgrammList extends StatelessWidget {
  final ProgrammCardType type;
  final Axis scrollDirection;

  const ProgrammList({
    super.key,
    required this.type,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgrammsBloc()..add(ProgrammsLoadEvent()),
      child: BlocBuilder<ProgrammsBloc, ProgrammsState>(
        builder: (context, state) {
          if (state is ProgrammsLoadingState) {
            return AppLoadingIndicator();
          }
          if (state is ProgrammLoadedState) {
            if (state.lessons.isEmpty) {
              return Text('Нет доступных занятий');
            }
            return ListView.builder(
              scrollDirection: scrollDirection,
              itemCount: state.lessons.length,
              itemBuilder: (context, index) {
                final lesson = state.lessons[index];
                return ProgrammCard(type: type, lesson: lesson);
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

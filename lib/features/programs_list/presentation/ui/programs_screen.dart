import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_bloc.dart';
import 'package:hygge_app/features/programs/bloc/programs_state.dart';

import 'programm_list.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramsBloc(),
      child: BlocBuilder<ProgramsBloc, ProgramsState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Программы')),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ProgrammList(
              type: ProgrammCardType.big,
              scrollDirection: Axis.vertical,
              lessons: state.visibleLessons,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'programm_list.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Программы')),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: ProgrammList(
          type: ProgrammCardType.big,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}

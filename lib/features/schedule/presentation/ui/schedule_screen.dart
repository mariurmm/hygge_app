import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: const Center(child: Text('Экран расписания')),
      ),
    );
  }
}

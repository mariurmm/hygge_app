part of 'programs_bloc.dart';

sealed class ProgramsEvent {
  const ProgramsEvent();
}

final class ProgramsInitialized extends ProgramsEvent {
  const ProgramsInitialized();
}

final class ProgramsRefreshRequested extends ProgramsEvent {
  const ProgramsRefreshRequested();
}

final class ProgramsFilterChanged extends ProgramsEvent {
  const ProgramsFilterChanged(this.filterIndex);
  final int filterIndex;
}

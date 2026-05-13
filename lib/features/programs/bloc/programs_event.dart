part of 'programs_bloc.dart';

abstract class ProgramsEvent extends Equatable {
  const ProgramsEvent();

  @override
  List<Object?> get props => [];
}

class ProgramsInitialized extends ProgramsEvent {
  const ProgramsInitialized({this.locale});

  final String? locale;

  @override
  List<Object?> get props => [locale];
}

class ProgramsRefreshRequested extends ProgramsEvent {
  const ProgramsRefreshRequested();
}

class ProgramsLocaleChanged extends ProgramsEvent {
  const ProgramsLocaleChanged(this.locale);

  final String locale;

  @override
  List<Object?> get props => [locale];
}

class ProgramsFilterChanged extends ProgramsEvent {
  const ProgramsFilterChanged(this.filterIndex);

  final int filterIndex;

  @override
  List<Object?> get props => [filterIndex];
}

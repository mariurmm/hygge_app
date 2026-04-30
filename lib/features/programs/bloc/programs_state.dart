part of 'programs_bloc.dart';

enum ProgramsFilter {
  all,
  meditation,
  yoga,
  outdoor,
  ceremony,
  masterClass,
  lecture,
  authorTour,
}

final class ProgramsState extends Equatable {
  final ProgramsFilter selectedFilter;
  final List<LessonModel> allLessons;

  const ProgramsState({
    this.selectedFilter = ProgramsFilter.all,
    this.allLessons = const [],
  });

  static const _keywords = {
    ProgramsFilter.meditation: ['медитац', 'meditation'],
    ProgramsFilter.yoga: ['йога', 'yoga'],
    ProgramsFilter.outdoor: ['outdoors', 'на улице', 'outdoor'],
    ProgramsFilter.ceremony: ['церемони', 'ceremony'],
    ProgramsFilter.masterClass: ['мастер', 'master class', 'masterclass'],
    ProgramsFilter.lecture: ['лекци', 'lecture'],
    ProgramsFilter.authorTour: ['тур', 'tour'],
  };

  List<LessonModel> get visibleLessons {
    if (selectedFilter == ProgramsFilter.all) return allLessons;
    final keys = _keywords[selectedFilter] ?? [];
    return allLessons.where((lesson) {
      final text = '${lesson.title} ${lesson.ritual}'.toLowerCase();
      return keys.any(text.contains);
    }).toList();
  }

  ProgramsState copyWith({
    ProgramsFilter? selectedFilter,
    List<LessonModel>? allLessons,
  }) {
    return ProgramsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allLessons: allLessons ?? this.allLessons,
    );
  }

  @override
  List<Object?> get props => [selectedFilter, allLessons];
}

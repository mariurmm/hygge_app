import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

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

class ProgramsState extends Equatable {
  final ProgramsFilter selectedFilter;
  final List<LessonModel> allLessons;
  final bool isLoading;

  const ProgramsState({
    this.selectedFilter = ProgramsFilter.all,
    this.allLessons = const [],
    this.isLoading = true,
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
    bool? isLoading,
  }) {
    return ProgramsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allLessons: allLessons ?? this.allLessons,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedFilter, allLessons, isLoading];
}

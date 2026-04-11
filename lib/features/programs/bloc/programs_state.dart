import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

enum ProgramsFilter { all, meditation, yoga }

class ProgramsState extends Equatable {
  final ProgramsFilter selectedFilter;
  final List<LessonModel> allLessons;
  final List<String> filters;

  const ProgramsState({
    this.selectedFilter = ProgramsFilter.all,
    this.allLessons = const [],
    this.filters = const ['Все программы', 'Медитации', 'Йога'],
  });

  List<LessonModel> get visibleLessons {
    switch (selectedFilter) {
      case ProgramsFilter.all:
        return allLessons;
      case ProgramsFilter.meditation:
        return allLessons
            .where((lesson) => lesson.title.toLowerCase().contains('медитац'))
            .toList();
      case ProgramsFilter.yoga:
        return allLessons
            .where((lesson) => lesson.title.toLowerCase().contains('йога'))
            .toList();
    }
  }

  ProgramsState copyWith({
    ProgramsFilter? selectedFilter,
    List<LessonModel>? allLessons,
    List<String>? filters,
  }) {
    return ProgramsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allLessons: allLessons ?? this.allLessons,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [selectedFilter, allLessons, filters];
}

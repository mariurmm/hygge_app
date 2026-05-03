part of 'programs_bloc.dart';

enum ProgramFilter { all, meditation, yoga, outdoor, ceremony, masterClass, lecture, authorTour }

class ProgramsState extends Equatable {
  final List<ProgramModel> allPrograms;
  final ProgramFilter selectedFilter;
  final Map<String, LessonModel> nearestLessonsByProgramId;
  final Map<String, MasterModel> mastersById;

  const ProgramsState({
    this.allPrograms = const [],
    this.selectedFilter = ProgramFilter.all,
    this.nearestLessonsByProgramId = const {},
    this.mastersById = const {},
  });

  List<ProgramModel> get visiblePrograms {
    if (selectedFilter == ProgramFilter.all) return allPrograms;

    return allPrograms
        .where((program) {
          return switch (selectedFilter) {
            ProgramFilter.meditation => program.category == ProgramCategory.meditation,
            ProgramFilter.yoga => program.category == ProgramCategory.yoga,
            ProgramFilter.outdoor => program.category == ProgramCategory.outdoor,
            ProgramFilter.ceremony => program.category == ProgramCategory.ceremony,
            ProgramFilter.masterClass => program.category == ProgramCategory.masterClass,
            ProgramFilter.lecture => program.category == ProgramCategory.lecture,
            ProgramFilter.authorTour => program.category == ProgramCategory.authorTour,
            ProgramFilter.all => true,
          };
        })
        .toList(growable: false);
  }

  ProgramsState copyWith({
    List<ProgramModel>? allPrograms,
    ProgramFilter? selectedFilter,
    Map<String, LessonModel>? nearestLessonsByProgramId,
    Map<String, MasterModel>? mastersById,
  }) {
    return ProgramsState(
      allPrograms: allPrograms ?? this.allPrograms,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      nearestLessonsByProgramId: nearestLessonsByProgramId ?? this.nearestLessonsByProgramId,
      mastersById: mastersById ?? this.mastersById,
    );
  }

  @override
  List<Object?> get props => [allPrograms, selectedFilter, nearestLessonsByProgramId, mastersById];
}

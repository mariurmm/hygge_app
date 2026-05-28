part of 'programs_bloc.dart';

enum ProgramFilter {
  all,
  meditation,
  yoga,
  outdoor,
  ceremony,
  masterClass,
  lecture,
  authorTour,
  masters,
}

class ProgramsState extends Equatable {
  const ProgramsState({
    this.locale = LocalizedValue.defaultLocale,
    this.allPrograms = const [],
    this.selectedFilter = ProgramFilter.all,
    this.nearestLessonsByProgramId = const {},
    this.mastersById = const {},
  });

  final String locale;
  final List<ProgramModel> allPrograms;
  final ProgramFilter selectedFilter;
  final Map<String, LessonModel> nearestLessonsByProgramId;
  final Map<String, MasterModel> mastersById;

  bool get isMastersFilterSelected {
    return selectedFilter == ProgramFilter.masters;
  }

  List<MasterModel> get visibleMasters {
    final masters =
        mastersById.values
            .where((master) => master.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) => a.fullName.compareTo(b.fullName));

    return masters;
  }

  List<ProgramModel> get visiblePrograms {
    if (selectedFilter == ProgramFilter.all) {
      return allPrograms;
    }

    if (selectedFilter == ProgramFilter.masters) {
      return const <ProgramModel>[];
    }

    final category = _categoryByFilter(selectedFilter);

    return allPrograms
        .where((program) => program.category == category)
        .toList(growable: false);
  }

  ProgramsState copyWith({
    String? locale,
    List<ProgramModel>? allPrograms,
    ProgramFilter? selectedFilter,
    Map<String, LessonModel>? nearestLessonsByProgramId,
    Map<String, MasterModel>? mastersById,
  }) {
    return ProgramsState(
      locale: locale ?? this.locale,
      allPrograms: allPrograms ?? this.allPrograms,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      nearestLessonsByProgramId:
          nearestLessonsByProgramId ?? this.nearestLessonsByProgramId,
      mastersById: mastersById ?? this.mastersById,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    allPrograms,
    selectedFilter,
    nearestLessonsByProgramId,
    mastersById,
  ];

  static ProgramCategory _categoryByFilter(ProgramFilter filter) {
    return switch (filter) {
      ProgramFilter.meditation => ProgramCategory.meditation,
      ProgramFilter.yoga => ProgramCategory.yoga,
      ProgramFilter.outdoor => ProgramCategory.outdoor,
      ProgramFilter.ceremony => ProgramCategory.ceremony,
      ProgramFilter.masterClass => ProgramCategory.masterClass,
      ProgramFilter.lecture => ProgramCategory.lecture,
      ProgramFilter.authorTour => ProgramCategory.authorTour,
      ProgramFilter.all || ProgramFilter.masters => ProgramCategory.yoga,
    };
  }
}

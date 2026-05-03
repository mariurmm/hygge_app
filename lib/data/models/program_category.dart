enum ProgramCategory {
  meditation,
  yoga,
  outdoor,
  ceremony,
  masterClass,
  lecture,
  authorTour;

  static ProgramCategory fromJson(String? value) {
    return switch (value) {
      'meditation' => ProgramCategory.meditation,
      'yoga' => ProgramCategory.yoga,
      'outdoor' => ProgramCategory.outdoor,
      'ceremony' => ProgramCategory.ceremony,
      'masterClass' => ProgramCategory.masterClass,
      'lecture' => ProgramCategory.lecture,
      'authorTour' => ProgramCategory.authorTour,
      _ => ProgramCategory.yoga,
    };
  }

  String toJson() {
    return switch (this) {
      ProgramCategory.meditation => 'meditation',
      ProgramCategory.yoga => 'yoga',
      ProgramCategory.outdoor => 'outdoor',
      ProgramCategory.ceremony => 'ceremony',
      ProgramCategory.masterClass => 'masterClass',
      ProgramCategory.lecture => 'lecture',
      ProgramCategory.authorTour => 'authorTour',
    };
  }
}

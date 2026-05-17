import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

enum ProgramDetailsStatus { initial, loading, loaded, error }

class ProgramDetailsState extends Equatable {
  const ProgramDetailsState({
    required this.program,
    required this.lesson,
    required this.master,
    this.availableLessons = const [],
    this.bookedLessonIds = const {},
    this.status = ProgramDetailsStatus.initial,
    this.isFavourite = false,
    this.errorMessage,
  });

  factory ProgramDetailsState.initial() {
    return ProgramDetailsState(
      program: ProgramModel.empty,
      lesson: LessonModel.empty,
      master: MasterModel.empty,
    );
  }

  final ProgramDetailsStatus status;
  final ProgramModel program;
  final LessonModel lesson;
  final MasterModel master;
  final List<LessonModel> availableLessons;
  final Set<String> bookedLessonIds;
  final bool isFavourite;
  final String? errorMessage;

  bool get hasSelectedLesson => lesson.isNotEmpty;
  bool get isSelectedLessonBooked =>
      lesson.isNotEmpty && bookedLessonIds.contains(lesson.id);

  ProgramDetailsState copyWith({
    ProgramDetailsStatus? status,
    ProgramModel? program,
    LessonModel? lesson,
    MasterModel? master,
    List<LessonModel>? availableLessons,
    Set<String>? bookedLessonIds,
    bool? isFavourite,
    String? errorMessage,
  }) {
    return ProgramDetailsState(
      status: status ?? this.status,
      program: program ?? this.program,
      lesson: lesson ?? this.lesson,
      master: master ?? this.master,
      availableLessons: availableLessons ?? this.availableLessons,
      bookedLessonIds: bookedLessonIds ?? this.bookedLessonIds,
      isFavourite: isFavourite ?? this.isFavourite,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    program,
    lesson,
    master,
    availableLessons,
    bookedLessonIds,
    isFavourite,
    errorMessage,
  ];
}

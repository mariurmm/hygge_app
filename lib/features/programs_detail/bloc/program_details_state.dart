import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

enum ProgramDetailsStatus { initial, loading, loaded, error }

class ProgramDetailsState extends Equatable {
  final ProgramDetailsStatus status;

  final ProgramModel program;
  final LessonModel lesson;
  final MasterModel master;

  final bool isFavourite;
  final bool isBooking;

  final String? errorMessage;

  const ProgramDetailsState({
    this.status = ProgramDetailsStatus.initial,
    required this.program,
    required this.lesson,
    required this.master,
    this.isFavourite = false,
    this.isBooking = false,
    this.errorMessage,
  });

  factory ProgramDetailsState.initial() {
    return ProgramDetailsState(program: ProgramModel.empty, lesson: LessonModel.empty, master: MasterModel.empty);
  }

  ProgramDetailsState copyWith({
    ProgramDetailsStatus? status,
    ProgramModel? program,
    LessonModel? lesson,
    MasterModel? master,
    bool? isFavourite,
    bool? isBooking,
    String? errorMessage,
  }) {
    return ProgramDetailsState(
      status: status ?? this.status,
      program: program ?? this.program,
      lesson: lesson ?? this.lesson,
      master: master ?? this.master,
      isFavourite: isFavourite ?? this.isFavourite,
      isBooking: isBooking ?? this.isBooking,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, program, lesson, master, isFavourite, isBooking, errorMessage];
}

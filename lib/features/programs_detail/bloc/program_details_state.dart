import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';

enum ProgramDetailsStatus { initial, loading, loaded, failure }

class ProgramDetailsState extends Equatable {
  final ProgramDetailsStatus status;
  final LessonModel program;
  final bool isFavourite;
  final bool isBooking;
  final String? errorMessage;

  const ProgramDetailsState({
    this.status = ProgramDetailsStatus.initial,
    required this.program,
    this.isFavourite = false,
    this.isBooking = false,
    this.errorMessage,
  });

  ProgramDetailsState copyWith({
    ProgramDetailsStatus? status,
    LessonModel? program,
    bool? isFavourite,
    bool? isBooking,
    String? errorMessage,
  }) {
    return ProgramDetailsState(
      status: status ?? this.status,
      program: program ?? this.program,
      isFavourite: isFavourite ?? this.isFavourite,
      isBooking: isBooking ?? this.isBooking,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    program,
    isFavourite,
    isBooking,
    errorMessage,
  ];
}

part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, success, failure }

final class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.lessons = const [],
    this.programsById = const {},
    this.mastersById = const {},
  });

  final HistoryStatus status;
  final List<LessonModel> lessons;
  final Map<String, ProgramModel> programsById;
  final Map<String, MasterModel> mastersById;

  bool get isLoading => status == HistoryStatus.loading;

  HistoryState copyWith({
    HistoryStatus? status,
    List<LessonModel>? lessons,
    Map<String, ProgramModel>? programsById,
    Map<String, MasterModel>? mastersById,
  }) {
    return HistoryState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      programsById: programsById ?? this.programsById,
      mastersById: mastersById ?? this.mastersById,
    );
  }

  @override
  List<Object?> get props => [status, lessons, programsById, mastersById];
}

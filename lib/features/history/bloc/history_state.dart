part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, success, failure }

final class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.lessons = const [],
  });

  final HistoryStatus status;
  final List<LessonModel> lessons;

  bool get isLoading => status == HistoryStatus.loading;

  HistoryState copyWith({
    HistoryStatus? status,
    List<LessonModel>? lessons,
  }) =>
      HistoryState(
        status: status ?? this.status,
        lessons: lessons ?? this.lessons,
      );

  @override
  List<Object?> get props => [status, lessons];
}
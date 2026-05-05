import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

final class HomeState extends Equatable {
  final List<LessonModel> lessons;
  final bool isLoading;
  final String? error;

  /// programId → ProgramModel
  final Map<String, ProgramModel> programsById;

  /// masterId → MasterModel
  final Map<String, MasterModel> mastersById;

  const HomeState({
    this.lessons = const [],
    this.isLoading = false,
    this.error,
    this.programsById = const {},
    this.mastersById = const {},
  });

  HomeState copyWith({
    List<LessonModel>? lessons,
    bool? isLoading,
    String? error,
    Map<String, ProgramModel>? programsById,
    Map<String, MasterModel>? mastersById,
  }) {
    return HomeState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      programsById: programsById ?? this.programsById,
      mastersById: mastersById ?? this.mastersById,
    );
  }

  @override
  List<Object?> get props => [
    lessons,
    isLoading,
    error,
    programsById,
    mastersById,
  ];
}

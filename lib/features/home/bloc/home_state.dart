import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';

final class HomeState extends Equatable {
  final List<LessonModel> lessons;
  final bool isLoading;

  /// programId → ProgramModel
  final Map<String, ProgramModel> programsById;

  /// masterId → MasterModel
  final Map<String, MasterModel> mastersById;

  const HomeState({
    this.lessons = const [],
    this.isLoading = false,
    this.programsById = const {},
    this.mastersById = const {},
  });

  HomeState copyWith({
    List<LessonModel>? lessons,
    bool? isLoading,
    Map<String, ProgramModel>? programsById,
    Map<String, MasterModel>? mastersById,
  }) {
    return HomeState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      programsById: programsById ?? this.programsById,
      mastersById: mastersById ?? this.mastersById,
    );
  }

  @override
  List<Object?> get props => [lessons, isLoading, programsById, mastersById];
}

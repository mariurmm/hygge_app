import 'package:hygge_app/data/models/lesson_model.dart';

class HomeState {
  final List<LessonModel> lessons;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.lessons = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<LessonModel>? lessons,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

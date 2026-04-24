import 'package:hygge_app/data/models/lesson_model.dart';

class HomeState {
  final List<LessonModel> lessons;
  final bool isLoading;

  const HomeState({this.lessons = const [], this.isLoading = false});

  HomeState copyWith({List<LessonModel>? lessons, bool? isLoading}) {
    return HomeState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

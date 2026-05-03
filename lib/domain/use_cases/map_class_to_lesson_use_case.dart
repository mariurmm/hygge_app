import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/schedule_repository.dart';

/// Maps a single [ClassModel] (from the schedule layer) into a [LessonModel]
/// (the domain representation used across features).
class MapClassToLessonUseCase {
  const MapClassToLessonUseCase({required ScheduleRepository scheduleRepository}) : _scheduleRepo = scheduleRepository;

  final ScheduleRepository _scheduleRepo;

  /// Fetches the class by [classId] and converts it.
  /// Returns null if the class doesn't exist in Firestore.
  Future<LessonModel?> call(String classId) async {
    final cls = await _scheduleRepo.getClass(classId);
    if (cls == null) return null;
    return _fromClass(cls);
  }

  /// Pure conversion — no async, useful for testing and direct mapping.
  LessonModel fromClass(ClassModel cls) => _fromClass(cls);

  static LessonModel _fromClass(ClassModel cls) {
    return LessonModel(
      id: cls.id,
      programId: '',
      trainerId: cls.trainerId,
      startDate: cls.startDate,
      endDate: cls.startDate.add(Duration(minutes: cls.durationMinutes)),
    );
  }
}

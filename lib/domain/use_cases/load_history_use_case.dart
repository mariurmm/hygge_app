import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/domain/use_cases/map_class_to_lesson_use_case.dart';

/// Result returned by [LoadHistoryUseCase].
class HistoryResult {
  const HistoryResult({
    required this.completedThisMonth,
    this.recentLesson,
  });

  /// Number of bookings whose date falls in the current calendar month.
  final int completedThisMonth;

  /// The most-recent booked lesson as a [LessonModel], or null when none.
  final LessonModel? recentLesson;
}

/// Loads the user's booking history and enriches it with class details.
///
/// Orchestrates [BookingRepository] + [MapClassToLessonUseCase]:
///   1. Fetches all bookings for [userId].
///   2. Counts bookings within the current calendar month.
///   3. Maps the most-recent booking's class into a [LessonModel].
class LoadHistoryUseCase {
  const LoadHistoryUseCase({
    required BookingRepository bookingRepository,
    required MapClassToLessonUseCase mapLesson,
  })  : _bookingRepo = bookingRepository,
        _mapLesson = mapLesson;

  final BookingRepository _bookingRepo;
  final MapClassToLessonUseCase _mapLesson;

  Future<HistoryResult> call(String userId) async {
    final bookings = await _bookingRepo.getBookingHistory(userId);
    final now = DateTime.now();

    final completedThisMonth = bookings
        .where((b) =>
            b.datetime.year == now.year && b.datetime.month == now.month)
        .length;

    LessonModel? recentLesson;
    if (bookings.isNotEmpty) {
      recentLesson = await _mapLesson(bookings.first.classId);
    }

    return HistoryResult(
      completedThisMonth: completedThisMonth,
      recentLesson: recentLesson,
    );
  }
}

import 'package:hygge_app/data/models/lesson_model.dart';

/// Interface for managing upcoming lessons and bookings.
///
/// This repository handles:
/// - Fetching upcoming programs (visible programs scheduled for the future)
/// - Fetching upcoming lessons (individual lesson instances)
/// - Managing user bookings (program reservations)
abstract class UpcomingLessonRepository {
  /// Fetch upcoming programs (visible programs for the future).
  ///
  /// [limit] - optional limit on the number of results.
  /// Returns a list of [LessonModel] representing upcoming programs.
  Future<List<LessonModel>> fetchUpcomingPrograms({int? limit});

  /// Watch upcoming programs as a stream.
  ///
  /// [limit] - optional limit on the number of results.
  /// Returns a stream of upcoming program lists.
  Stream<List<LessonModel>> watchUpcomingPrograms({int? limit});

  /// Fetch upcoming lessons by program ID.
  ///
  /// [programId] - the unique identifier of the program.
  /// Returns a list of [LessonModel] representing lessons for that program.
  Future<List<LessonModel>> fetchLessonsByProgramId(String programId);

  /// Fetch upcoming lessons (individual instances in the future).
  ///
  /// [limit] - maximum number of lessons to return (default: 10).
  /// Returns a list of [LessonModel] representing upcoming lessons.
  Future<List<LessonModel>> fetchUpcomingLessons({int limit = 10});

  /// Fetch user bookings (reservations for lessons).
  ///
  ///[status] - optional filter by booking status (e.g., 'booked', 'completed').
  /// Returns a list of [LessonModel] representing booked lessons.
  Future<List<LessonModel>> fetchBookings({String? status});

  /// Book a program/lesson for the current user.
  ///
  /// [lesson] - the [LessonModel] to book.
  /// Creates a booking record in the user's bookings subcollection.
  Future<void> bookProgram(LessonModel lesson);

  /// Cancel a booking for the current user.
  ///
  /// [bookingId] - the unique identifier of the booking to cancel.
  /// Updates the booking status to 'cancelled' in Firestore.
  Future<void> cancelBooking(String bookingId);
}

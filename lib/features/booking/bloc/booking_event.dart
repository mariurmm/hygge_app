part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

final class BookingCheckStatusEvent extends BookingEvent {
  const BookingCheckStatusEvent({required this.classId});
  final String classId;

  @override
  List<Object?> get props => [classId];
}

final class BookingBookClassEvent extends BookingEvent {
  const BookingBookClassEvent({
    required this.classModel,
    required this.whatsAppMessage,
  });
  final ClassModel classModel;
  final String whatsAppMessage;

  @override
  List<Object?> get props => [classModel, whatsAppMessage];
}

final class BookingBookLessonEvent extends BookingEvent {
  const BookingBookLessonEvent({
    required this.lesson,
    required this.programTitle,
    required this.whatsAppMessage,
  });
  final LessonModel lesson;
  final String programTitle;
  final String whatsAppMessage;

  @override
  List<Object?> get props => [lesson, programTitle, whatsAppMessage];
}

final class BookingRequestCancelEvent extends BookingEvent {
  const BookingRequestCancelEvent();
}

final class BookingConfirmCancelEvent extends BookingEvent {
  const BookingConfirmCancelEvent({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

final class BookingResetEvent extends BookingEvent {
  const BookingResetEvent();
}

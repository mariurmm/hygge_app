part of 'booking_cubit.dart';

enum BookingStatus2 {
  idle,
  loading,
  success,
  cancelled,
  error,
  alreadyBooked,
  noSubscription,
  classFull,
  externalBookingRequired,
}

class BookingState extends Equatable {
  final BookingStatus2 status;
  final String? message;
  final BookingModel? existingBooking;

  const BookingState({
    this.status = BookingStatus2.idle,
    this.message,
    this.existingBooking,
  });

  BookingState copyWith({
    BookingStatus2? status,
    String? message,
    BookingModel? existingBooking,
  }) {
    return BookingState(
      status: status ?? this.status,
      message: message ?? this.message,
      existingBooking: existingBooking ?? this.existingBooking,
    );
  }

  @override
  List<Object?> get props => [status, message, existingBooking];
}

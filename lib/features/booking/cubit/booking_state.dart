part of 'booking_cubit.dart';

enum BookingCubitStatus {
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
  final BookingCubitStatus status;
  final String? message;
  final BookingModel? existingBooking;

  const BookingState({
    this.status = BookingCubitStatus.idle,
    this.message,
    this.existingBooking,
  });

  BookingState copyWith({
    BookingCubitStatus? status,
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

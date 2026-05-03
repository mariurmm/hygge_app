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
  cancelConfirmationRequired,
}

class BookingState extends Equatable {
  final BookingCubitStatus status;
  final String? message;
  final BookingModel? existingBooking;

  const BookingState({this.status = BookingCubitStatus.idle, this.message, this.existingBooking});

  static const _absent = Object();

  BookingState copyWith({BookingCubitStatus? status, Object? message = _absent, Object? existingBooking = _absent}) {
    return BookingState(
      status: status ?? this.status,
      message: identical(message, _absent) ? this.message : message as String?,
      existingBooking: identical(existingBooking, _absent) ? this.existingBooking : existingBooking as BookingModel?,
    );
  }

  @override
  List<Object?> get props => [status, message, existingBooking];
}

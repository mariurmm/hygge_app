part of 'booking_bloc.dart';

enum BookingUiStatus {
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

final class BookingState extends Equatable {
  const BookingState({
    this.status = BookingUiStatus.idle,
    this.errorMessage,
    this.existingBooking,
  });

  final BookingUiStatus status;
  final String? errorMessage;
  final BookingModel? existingBooking;

  static const _absent = Object();

  BookingState copyWith({
    BookingUiStatus? status,
    Object? errorMessage = _absent,
    Object? existingBooking = _absent,
  }) {
    return BookingState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _absent)
          ? this.errorMessage
          : errorMessage as String?,
      existingBooking: identical(existingBooking, _absent)
          ? this.existingBooking
          : existingBooking as BookingModel?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, existingBooking];
}

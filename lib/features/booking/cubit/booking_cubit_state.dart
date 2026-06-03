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
  cancelConfirmationRequired,
}

final class BookingCubitState extends Equatable {
  const BookingCubitState({
    this.status = BookingCubitStatus.idle,
    this.errorMessage,
    this.message,
    this.existingBooking,
  });

  final BookingCubitStatus status;
  final String? errorMessage;

  /// Информационное сообщение (например, «Запись отменена»).
  final String? message;

  final BookingModel? existingBooking;

  static const _absent = Object();

  BookingCubitState copyWith({
    BookingCubitStatus? status,
    Object? errorMessage = _absent,
    Object? message = _absent,
    Object? existingBooking = _absent,
  }) {
    return BookingCubitState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _absent)
          ? this.errorMessage
          : errorMessage as String?,
      message: identical(message, _absent) ? this.message : message as String?,
      existingBooking: identical(existingBooking, _absent)
          ? this.existingBooking
          : existingBooking as BookingModel?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, message, existingBooking];
}

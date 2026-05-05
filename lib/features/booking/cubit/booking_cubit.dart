import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required BookingRepository bookingRepo,
    required SubscriptionRepository subscriptionRepo,
    required this.userId,
  }) : _bookingRepo = bookingRepo,
       _subscriptionRepo = subscriptionRepo,
       super(const BookingState());
  final BookingRepository _bookingRepo;
  final SubscriptionRepository _subscriptionRepo;
  final String userId;

  Future<void> bookClass(ClassModel classModel) async {
    emit(state.copyWith(status: BookingCubitStatus.loading));

    try {
      // 1. Проверяем — уже есть бронь?
      final existing = await _bookingRepo.getBookingForClass(
        userId,
        classModel.id,
      );
      if (existing != null) {
        emit(
          state.copyWith(
            status: BookingCubitStatus.alreadyBooked,
            message: 'Вы уже записаны на это занятие',
          ),
        );
        return;
      }

      // 2. Для выездных практик/туров — блокируем с сообщением
      if (!classModel.isIncludedInSubscription) {
        emit(
          state.copyWith(
            status: BookingCubitStatus.externalBookingRequired,
            message: 'Запись через администратора',
          ),
        );
        return;
      }

      // 3. Проверяем наличие активного абонемента
      final subscription = await _subscriptionRepo.getSubscription(userId);
      if (subscription == null || !subscription.isValid) {
        emit(
          state.copyWith(
            status: BookingCubitStatus.noSubscription,
            message: 'Для записи необходим активный абонемент',
          ),
        );
        return;
      }

      // 4. Проверяем места
      if (classModel.isFull) {
        emit(
          state.copyWith(
            status: BookingCubitStatus.classFull,
            message: 'На это занятие нет свободных мест',
          ),
        );
        return;
      }

      // 5. Создаём бронь (счётчик участников обновляется через Cloud Function)
      await _bookingRepo.createBooking(
        userId,
        classModel.id,
        classModel.startDate,
      );

      emit(
        state.copyWith(
          status: BookingCubitStatus.success,
          message: 'Вы записаны на «${classModel.title}»',
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingCubitStatus.error,
          message: 'Ошибка записи: $e',
        ),
      );
    }
  }

  /// Signals the UI to show a cancel-confirmation dialog.
  /// The dialog outcome drives the actual [cancelBooking] call.
  void requestCancelBooking() {
    final bookingId = state.existingBooking?.id;
    if (bookingId == null) return;
    emit(state.copyWith(status: BookingCubitStatus.cancelConfirmationRequired));
  }

  Future<void> cancelBooking(String bookingId) async {
    emit(state.copyWith(status: BookingCubitStatus.loading));
    try {
      await _bookingRepo.updateBookingStatus(
        userId,
        bookingId,
        BookingStatus.cancelled,
      );
      emit(
        const BookingState(
          status: BookingCubitStatus.cancelled,
          message: 'Запись отменена',
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingCubitStatus.error,
          message: 'Ошибка отмены: $e',
        ),
      );
    }
  }

  Future<void> checkBookingStatus(String classId) async {
    final existing = await _bookingRepo.getBookingForClass(userId, classId);
    emit(
      state.copyWith(
        existingBooking: existing,
        status: BookingCubitStatus.idle,
      ),
    );
  }

  void reset() => emit(const BookingState());
}

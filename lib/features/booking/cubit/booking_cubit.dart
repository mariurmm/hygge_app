import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/failure.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

part 'booking_cubit_state.dart';

/// Cubit-обёртка над логикой бронирования.
///
/// Используется там, где не нужен полноценный BLoC с событиями —
/// например, в юнит-тестах и в простых виджетах.
///
/// Демо-режим ([demoMode] = true) позволяет записываться на занятия
/// без реального абонемента и без списания сессий. Нужен для
/// презентаций, когда запись идёт только через менеджера в WhatsApp.
/// После выхода в продакшн переключить на false.
class BookingCubit extends Cubit<BookingCubitState> {
  BookingCubit({
    required BookingRepository bookingRepo,
    required SubscriptionRepository subscriptionRepo,
    required this.userId,
    this.demoMode = true,
  }) : _bookingRepo = bookingRepo,
       _subscriptionRepo = subscriptionRepo,
       super(const BookingCubitState());

  final BookingRepository _bookingRepo;
  final SubscriptionRepository _subscriptionRepo;

  final String userId;

  /// Если true — абонемент не проверяется, сессии не списываются.
  /// Записи не влияют на количество мест (currentParticipants
  /// в Firestore всё равно обновляется транзакцией).
  final bool demoMode;

  // ── Public API ───────────────────────────────────────────────

  /// Записывает пользователя на занятие.
  ///
  /// Порядок проверок:
  /// 1. Уже записан → [BookingCubitStatus.alreadyBooked]
  /// 2. Нет мест → [BookingCubitStatus.classFull]
  /// 3. Нет активного абонемента (только вне demoMode) →
  ///    [BookingCubitStatus.noSubscription]
  /// 4. Успех → [BookingCubitStatus.success]
  Future<void> bookClass(ClassModel classModel) async {
    emit(state.copyWith(status: BookingCubitStatus.loading));

    try {
      final existing = await _bookingRepo.getBookingForClass(
        userId,
        classModel.id,
      );

      if (existing != null) {
        emit(
          state.copyWith(
            status: BookingCubitStatus.alreadyBooked,
            existingBooking: existing,
          ),
        );
        return;
      }

      if (classModel.isFull) {
        emit(state.copyWith(status: BookingCubitStatus.classFull));
        return;
      }

      if (!demoMode) {
        final subscription = await _subscriptionRepo.getSubscription(userId);

        if (subscription == null || !subscription.isValid) {
          emit(state.copyWith(status: BookingCubitStatus.noSubscription));
          return;
        }
      }

      final booking = await _bookingRepo.createBooking(
        userId,
        classModel.id,
        classModel.startDate,
      );

      if (!demoMode) {
        await _subscriptionRepo.deductSession(userId);
      }

      emit(
        state.copyWith(
          status: BookingCubitStatus.success,
          existingBooking: booking,
        ),
      );
    } on ClassFullFailure {
      emit(state.copyWith(status: BookingCubitStatus.classFull));
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingCubitStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Показывает диалог подтверждения отмены (если запись существует).
  void requestCancelBooking() {
    if (state.existingBooking == null) return;

    emit(state.copyWith(status: BookingCubitStatus.cancelConfirmationRequired));
  }

  /// Выполняет отмену записи по [bookingId].
  Future<void> cancelBooking(String bookingId) async {
    emit(state.copyWith(status: BookingCubitStatus.loading));

    try {
      await _bookingRepo.updateBookingStatus(
        userId,
        bookingId,
        BookingStatus.cancelled,
      );

      emit(
        state.copyWith(
          status: BookingCubitStatus.cancelled,
          message: 'Запись отменена',
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingCubitStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Сбрасывает состояние в [BookingCubitStatus.idle].
  void reset() => emit(const BookingCubitState());
}

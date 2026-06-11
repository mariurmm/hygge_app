import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/core/utils/failure.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required BookingRepository bookingRepo,
    required SubscriptionRepository subscriptionRepo,
    required this.whatsAppService,
  }) : _bookingRepo = bookingRepo,
       _subscriptionRepo = subscriptionRepo,
       super(const BookingState()) {
    on<BookingCheckStatusEvent>(_onCheckStatus);
    on<BookingBookClassEvent>(_onBookClass);
    on<BookingRequestCancelEvent>(_onRequestCancel);
    on<BookingConfirmCancelEvent>(_onConfirmCancel);
    on<BookingResetEvent>((_, emit) {
      emit(const BookingState());
    });
    on<BookingBookLessonEvent>(_onBookLesson);
  }

  /// Для дипломной демонстрации.
  /// После защиты просто поменять на false.
  static const bool demoMode = true;

  final BookingRepository _bookingRepo;
  final SubscriptionRepository _subscriptionRepo;

  final WhatsAppService whatsAppService;

  /// Always reads the live UID — never stale from constructor time.
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onCheckStatus(
    BookingCheckStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    final uid = _uid;
    if (uid.isEmpty) return;

    final existing = await _bookingRepo.getBookingForClass(uid, event.classId);

    emit(
      state.copyWith(
        existingBooking: existing,
        status: BookingUiStatus.idle,
      ),
    );
  }

  Future<void> _onBookClass(
    BookingBookClassEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingUiStatus.loading));

    final uid = _uid;
    if (uid.isEmpty) {
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: 'Пользователь не авторизован',
        ),
      );
      return;
    }

    final classModel = event.classModel;

    try {
      final existing = await _bookingRepo.getBookingForClass(
        uid,
        classModel.id,
      );

      if (existing != null) {
        emit(
          state.copyWith(
            status: BookingUiStatus.alreadyBooked,
            existingBooking: existing,
          ),
        );
        return;
      }

      if (classModel.isFull) {
        emit(state.copyWith(status: BookingUiStatus.classFull));
        return;
      }

      if (!demoMode) {
        if (!classModel.isIncludedInSubscription) {
          unawaited(whatsAppService.open(event.whatsAppMessage));
          emit(state.copyWith(status: BookingUiStatus.externalBookingRequired));
          return;
        }

        final subscription = await _subscriptionRepo.getSubscription(uid);

        if (subscription == null || !subscription.isValid) {
          unawaited(whatsAppService.open(event.whatsAppMessage));
          emit(state.copyWith(status: BookingUiStatus.noSubscription));
          return;
        }
      }

      AppLogger.info('BOOKING: uid=$uid, classId=${classModel.id}');
      final booking = await _bookingRepo.createBooking(
        uid,
        classModel.id,
        classModel.startDate,
      );
      AppLogger.info('BOOKING: created ${booking.id}');

      if (!demoMode) {
        await _subscriptionRepo.deductSession(uid);
      }

      emit(
        state.copyWith(
          status: BookingUiStatus.success,
          existingBooking: booking,
        ),
      );
    } on ClassFullFailure {
      emit(state.copyWith(status: BookingUiStatus.classFull));
    } on Object catch (e) {
      AppLogger.error('BOOKING ERROR', error: e);
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onRequestCancel(
    BookingRequestCancelEvent event,
    Emitter<BookingState> emit,
  ) {
    if (state.existingBooking?.id == null) return;

    emit(state.copyWith(status: BookingUiStatus.cancelConfirmationRequired));
  }

  Future<void> _onConfirmCancel(
    BookingConfirmCancelEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingUiStatus.loading));

    try {
      await _bookingRepo.updateBookingStatus(
        _uid,
        event.bookingId,
        BookingStatus.cancelled,
      );

      emit(const BookingState(status: BookingUiStatus.cancelled));
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onBookLesson(
    BookingBookLessonEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingUiStatus.loading));

    final uid = _uid;
    AppLogger.info(
      'BookingBloc._onBookLesson: uid="$uid", lessonId="${event.lesson.id}"',
    );

    if (uid.isEmpty) {
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: 'Пользователь не авторизован',
        ),
      );
      return;
    }

    try {
      if (!demoMode) {
        final subscription = await _subscriptionRepo.getSubscription(uid);

        if (subscription == null || !subscription.isValid) {
          unawaited(whatsAppService.open(event.whatsAppMessage));
          emit(state.copyWith(status: BookingUiStatus.noSubscription));
          return;
        }
      }

      await _bookingRepo.bookLesson(
        uid,
        event.lesson.id,
        event.lesson.startDate,
      );

      if (!demoMode) {
        await _subscriptionRepo.deductSession(uid);
      }

      emit(state.copyWith(status: BookingUiStatus.success));
    } on ClassFullFailure {
      emit(state.copyWith(status: BookingUiStatus.classFull));
    } on Object catch (e) {
      AppLogger.error('BOOKING LESSON ERROR', error: e);
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

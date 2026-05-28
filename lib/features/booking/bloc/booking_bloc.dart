import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/services/whatsapp_service.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/repositories/booking_repository.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';
import 'package:hygge_app/data/repositories/upcoming_lesson_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required BookingRepository bookingRepo,
    required SubscriptionRepository subscriptionRepo,
    required UpcomingLessonRepository upcomingLessonRepo,
    required this.userId,
    required this.whatsAppService,
  }) : _bookingRepo = bookingRepo,
       _subscriptionRepo = subscriptionRepo,
       _upcomingLessonRepo = upcomingLessonRepo,
       super(const BookingState()) {
    on<BookingCheckStatusEvent>(_onCheckStatus);
    on<BookingBookClassEvent>(_onBookClass);
    on<BookingRequestCancelEvent>(_onRequestCancel);
    on<BookingConfirmCancelEvent>(_onConfirmCancel);
    on<BookingResetEvent>((_, emit) => emit(const BookingState()));
    on<BookingBookLessonEvent>(_onBookLesson);
  }

  final BookingRepository _bookingRepo;
  final SubscriptionRepository _subscriptionRepo;
  final UpcomingLessonRepository _upcomingLessonRepo;
  final WhatsAppService whatsAppService;
  final String userId;

  Future<void> _onCheckStatus(
    BookingCheckStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    final existing = await _bookingRepo.getBookingForClass(
      userId,
      event.classId,
    );
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

    final classModel = event.classModel;

    try {
      final existing = await _bookingRepo.getBookingForClass(
        userId,
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

      if (!classModel.isIncludedInSubscription) {
        unawaited(
          whatsAppService.open(event.whatsAppMessage),
        );
        emit(
          state.copyWith(
            status: BookingUiStatus.externalBookingRequired,
            existingBooking: existing,
          ),
        );
        return;
      }

      final subscription = await _subscriptionRepo.getSubscription(userId);
      if (subscription == null || !subscription.isValid) {
        unawaited(whatsAppService.open(event.whatsAppMessage));
        emit(state.copyWith(status: BookingUiStatus.noSubscription));
        return;
      }

      if (classModel.isFull) {
        emit(state.copyWith(status: BookingUiStatus.classFull));
        return;
      }

      final booking = await _bookingRepo.createBooking(
        userId,
        classModel.id,
        classModel.startDate,
      );

      emit(
        state.copyWith(
          status: BookingUiStatus.success,
          existingBooking: booking,
        ),
      );
    } on Object catch (e) {
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
        userId,
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
    try {
      final subscription = await _subscriptionRepo.getSubscription(userId);
      if (subscription == null || !subscription.isValid) {
        unawaited(whatsAppService.open(event.whatsAppMessage));
        emit(state.copyWith(status: BookingUiStatus.noSubscription));
        return;
      }

      await _upcomingLessonRepo.bookProgram(event.lesson);
      await _subscriptionRepo.deductSession(userId);

      emit(state.copyWith(status: BookingUiStatus.success));
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BookingUiStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

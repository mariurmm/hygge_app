import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    required SubscriptionRepository repository,
    required this.userId,
  })  : _repository = repository,
        super(const SubscriptionState()) {
    on<SubscriptionStarted>(_onStarted);
    on<SubscriptionDeductSession>(_onDeductSession);
  }

  final SubscriptionRepository _repository;
  final String userId;
  StreamSubscription<SubscriptionModel?>? _sub;

  Future<void> _onStarted(
    SubscriptionStarted event,
    Emitter<SubscriptionState> emit,
  ) async {
    await emit.forEach<SubscriptionModel?>(
      _repository.watchSubscription(userId),
      onData: (subscription) => state.copyWith(
        status: SubscriptionStatus.loaded,
        subscription: subscription,
      ),
      onError: (e, st) {
        AppLogger.error(
          'SubscriptionBloc: ошибка watchSubscription',
          error: e,
          stackTrace: st,
        );
        return state.copyWith(
          status: SubscriptionStatus.error,
          error: e.toString(),
        );
      },
    );
  }

  Future<void> _onDeductSession(
    SubscriptionDeductSession event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await _repository.deductSession(userId);
    } on Object catch (e, st) {
      AppLogger.error(
        'SubscriptionBloc: ошибка deductSession',
        error: e,
        stackTrace: st,
      );
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
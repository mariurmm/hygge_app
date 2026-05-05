import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:hygge_app/data/repositories/subscription_repository.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required SubscriptionRepository repository,
    required this.userId,
  }) : _repository = repository,
       super(const SubscriptionState()) {
    _subscribe();
  }
  final SubscriptionRepository _repository;
  final String userId;

  StreamSubscription<SubscriptionModel?>? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repository
        .watchSubscription(userId)
        .listen(
          (subscription) => emit(
            state.copyWith(
              status: SubscriptionStatus.loaded,
              subscription: subscription,
            ),
          ),
          onError: (Object e) => emit(
            state.copyWith(
              status: SubscriptionStatus.error,
              error: e.toString(),
            ),
          ),
        );
  }

  Future<void> deductSession() async {
    try {
      await _repository.deductSession(userId);
    } on Object catch (e) {
      emit(
        state.copyWith(status: SubscriptionStatus.error, error: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/subscription_model.dart';
import '../../../data/repositories/subscription_repository.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;
  final String userId;

  StreamSubscription<SubscriptionModel?>? _sub;

  SubscriptionCubit({required SubscriptionRepository repository, required this.userId})
    : _repository = repository,
      super(const SubscriptionState()) {
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _repository
        .watchSubscription(userId)
        .listen(
          (subscription) => emit(state.copyWith(status: SubscriptionStatus.loaded, subscription: subscription)),
          onError: (e) => emit(state.copyWith(status: SubscriptionStatus.error, error: e.toString())),
        );
  }

  Future<void> deductSession() async {
    try {
      await _repository.deductSession(userId);
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

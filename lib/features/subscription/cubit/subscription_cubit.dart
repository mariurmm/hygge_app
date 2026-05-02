import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/subscription_model.dart';
import '../../../data/repositories/subscription_repository.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repo;
  final String userId;

  StreamSubscription<SubscriptionModel?>? _sub;

  SubscriptionCubit({
    required SubscriptionRepository repo,
    required this.userId,
  })  : _repo = repo,
        super(const SubscriptionState()) {
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchSubscription(userId).listen(
      (subscription) => emit(state.copyWith(
        status: SubscriptionStatus.loaded,
        subscription: subscription,
      )),
      onError: (e) => emit(state.copyWith(
        status: SubscriptionStatus.error,
        error: e.toString(),
      )),
    );
  }

  Future<void> deductSession() async {
    try {
      await _repo.deductSession(userId);
    } catch (e) {
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

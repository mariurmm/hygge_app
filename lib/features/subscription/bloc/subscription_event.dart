part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

final class SubscriptionStarted extends SubscriptionEvent {
  const SubscriptionStarted();
}

final class SubscriptionDeductSession extends SubscriptionEvent {
  const SubscriptionDeductSession();
}
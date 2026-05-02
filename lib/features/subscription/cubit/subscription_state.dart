part of 'subscription_cubit.dart';

enum SubscriptionStatus { initial, loaded, error }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final SubscriptionModel? subscription;
  final String? error;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.subscription,
    this.error,
  });

  bool get hasActiveSubscription =>
      subscription != null && subscription!.isValid;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    SubscriptionModel? subscription,
    String? error,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, subscription, error];
}

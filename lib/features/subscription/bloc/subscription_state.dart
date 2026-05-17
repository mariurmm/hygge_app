part of 'subscription_bloc.dart';

enum SubscriptionStatus { initial, loaded, error }

final class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.subscription,
    this.error,
  });

  final SubscriptionStatus status;
  final SubscriptionModel? subscription;
  final String? error;

  bool get hasActiveSubscription =>
      subscription != null && subscription!.isValid;

  static const _absent = Object();

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    Object? subscription = _absent,
    String? error,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscription: identical(subscription, _absent)
          ? this.subscription
          : subscription as SubscriptionModel?,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, subscription, error];
}
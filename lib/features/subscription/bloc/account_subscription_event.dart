import 'package:equatable/equatable.dart';

abstract class AccountSubscriptionEvent extends Equatable {
  const AccountSubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class AccountSubscriptionStarted extends AccountSubscriptionEvent {
  const AccountSubscriptionStarted();
}
import 'package:equatable/equatable.dart';
import 'package:hygge_app/data/models/user_model.dart';

enum AccountSubscriptionStatus { initial, loading, loaded, failure }

class AccountSubscriptionState extends Equatable {
  final AccountSubscriptionStatus status;
  final UserModel user;
  final String? errorMessage;

  const AccountSubscriptionState({
    this.status = AccountSubscriptionStatus.initial,
    this.user = UserModel.empty,
    this.errorMessage,
  });

  AccountSubscriptionState copyWith({AccountSubscriptionStatus? status, UserModel? user, String? errorMessage}) {
    return AccountSubscriptionState(status: status ?? this.status, user: user ?? this.user, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

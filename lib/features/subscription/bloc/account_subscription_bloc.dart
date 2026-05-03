import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository_impl.dart';
import 'account_subscription_event.dart';
import 'account_subscription_state.dart';

class AccountSubscriptionBloc extends Bloc<AccountSubscriptionEvent, AccountSubscriptionState> {
  final UserRepository _repository;

  AccountSubscriptionBloc({UserRepository? repository})
    : _repository = repository ?? UserRepositoryImpl(),
      super(const AccountSubscriptionState()) {
    on<AccountSubscriptionStarted>(_onStarted);
  }

  Future<void> _onStarted(AccountSubscriptionStarted event, Emitter<AccountSubscriptionState> emit) async {
    emit(state.copyWith(status: AccountSubscriptionStatus.loading));

    try {
      final user = await _repository.getCurrentUser();

      emit(state.copyWith(status: AccountSubscriptionStatus.loaded, user: user));
    } catch (_) {
      emit(
        state.copyWith(status: AccountSubscriptionStatus.failure, errorMessage: 'Не удалось загрузить данные аккаунта'),
      );
    }
  }
}

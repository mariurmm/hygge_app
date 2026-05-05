import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository.dart';

import 'account_subscription_event.dart';
import 'account_subscription_state.dart';

class AccountSubscriptionBloc
    extends Bloc<AccountSubscriptionEvent, AccountSubscriptionState> {
  final UserRepository _repository;

  AccountSubscriptionBloc({required UserRepository repository})
    : _repository = repository,
      super(const AccountSubscriptionState()) {
    on<AccountSubscriptionStarted>(_onStarted);
  }

  Future<void> _onStarted(
    AccountSubscriptionStarted event,
    Emitter<AccountSubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: AccountSubscriptionStatus.loading));

    try {
      final user = await _repository.getCurrentUser();
      emit(
        state.copyWith(status: AccountSubscriptionStatus.loaded, user: user),
      );
    } on Exception catch (e, st) {
      AppLogger.error(
        'AccountSubscriptionBloc: ошибка загрузки',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: AccountSubscriptionStatus.failure,
          errorMessage: 'Не удалось загрузить данные аккаунта',
        ),
      );
    }
  }
}

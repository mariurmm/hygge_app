import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';
import 'account_subscription_event.dart';
import 'account_subscription_state.dart';

class AccountSubscriptionBloc
    extends Bloc<AccountSubscriptionEvent, AccountSubscriptionState> {
  final FirebaseFeatureRepository repository;

  AccountSubscriptionBloc({required this.repository})
    : super(const AccountSubscriptionState()) {
    on<AccountSubscriptionStarted>(_onStarted);
  }

  Future<void> _onStarted(
    AccountSubscriptionStarted event,
    Emitter<AccountSubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: AccountSubscriptionStatus.loading));

    try {
      final user = await repository.getCurrentUser();

      emit(
        state.copyWith(status: AccountSubscriptionStatus.loaded, user: user),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountSubscriptionStatus.failure,
          errorMessage: 'Не удалось загрузить данные аккаунта',
        ),
      );
    }
  }
}

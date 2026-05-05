import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart' show AppBloc;
import 'package:hygge_app/features/app/bloc/app_state.dart' show AppState;

/// События (events) для [AppBloc].
///
/// Event — это «что произошло». BLoC реагирует на события
/// и меняет состояние (state).
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Изменился статус авторизации (пришёл новый User из стрима).
///
/// Отправляется автоматически при подписке на `authStateChanges`.
class AppAuthStateChanged extends AppEvent {
  const AppAuthStateChanged(this.user);

  /// Новый пользователь (или [UserModel.empty] при выходе).
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

/// Пользователь нажал «Выйти».
class AppSignOutRequested extends AppEvent {
  const AppSignOutRequested();
}

/// Принудительно обновить пользователя из Firebase Auth.
///
/// Отправляется после успешного сохранения профиля в настройках,
/// чтобы [AppBloc] перечитал актуальные данные и обновил [AppState].
class AppUserRefreshRequested extends AppEvent {
  const AppUserRefreshRequested();
}

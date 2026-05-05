import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart' show AppBloc;

/// Состояния (states) для [AppBloc].
///
/// State — это «как сейчас выглядит приложение».
/// UI перестраивается каждый раз, когда BLoC эмитит новый state.

/// Перечисление статусов авторизации.
enum AppStatus {
  /// Ещё не определили, вошёл ли пользователь.
  unknown,

  /// Пользователь авторизован.
  authenticated,

  /// Пользователь не авторизован.
  unauthenticated,
}

/// Состояние приложения.
class AppState extends Equatable {
  const AppState({required this.status, this.user = UserModel.empty});

  /// Начальное состояние — статус неизвестен.
  const AppState.unknown() : status = AppStatus.unknown, user = UserModel.empty;

  /// Пользователь авторизован.
  const AppState.authenticated(this.user) : status = AppStatus.authenticated;

  /// Пользователь не авторизован.
  const AppState.unauthenticated()
    : status = AppStatus.unauthenticated,
      user = UserModel.empty;

  /// Текущий статус авторизации.
  final AppStatus status;

  /// Текущий пользователь.
  final UserModel user;

  @override
  List<Object?> get props => [status, user];
}

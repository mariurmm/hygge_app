import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/utils/logger.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app_event.dart';
import 'app_state.dart';

/// Глобальный BLoC авторизации.
///
/// Подписывается на стрим `authStateChanges` из [AuthRepository]
/// и транслирует изменения в [AppState].
///
/// Живёт на уровне всего приложения (оборачивает MaterialApp),
/// поэтому любой экран может прочитать текущего пользователя.
class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository _authRepository;

  /// Подписка на стрим авторизации.
  late final StreamSubscription<UserModel> _authSubscription;

  AppBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AppState.unknown()) {
    // Регистрируем обработчики событий.
    on<AppAuthStateChanged>(_onAuthStateChanged);
    on<AppSignOutRequested>(_onSignOutRequested);
    on<AppUserRefreshRequested>(_onUserRefreshRequested);

    // Подписываемся на стрим авторизации.
    // Каждый раз, когда пользователь входит/выходит,
    // стрим присылает нового [UserModel].
    _authSubscription = _authRepository.authStateChanges.listen((
      UserModel user,
    ) {
      add(AppAuthStateChanged(user));
    });
  }

  /// Обработчик: изменился статус авторизации.
  void _onAuthStateChanged(AppAuthStateChanged event, Emitter<AppState> emit) {
    if (event.user.isNotEmpty) {
      AppLogger.info('AppBloc: пользователь авторизован — ${event.user.email}');
      Sentry.configureScope(
        (scope) => scope.setUser(
          SentryUser(id: event.user.uid, email: event.user.email),
        ),
      );
      emit(AppState.authenticated(event.user));
    } else {
      AppLogger.info('AppBloc: пользователь не авторизован');
      Sentry.configureScope((scope) => scope.setUser(null));
      emit(const AppState.unauthenticated());
    }
  }

  /// Обработчик: пользователь нажал «Выйти».
  Future<void> _onSignOutRequested(
    AppSignOutRequested event,
    Emitter<AppState> emit,
  ) async {
    await _authRepository.signOut();
    // Стрим authStateChanges сам пришлёт AppAuthStateChanged(empty),
    // поэтому emit здесь не нужен.
  }

  /// Обработчик: принудительное обновление профиля пользователя.
  ///
  /// Вызывается после сохранения настроек профиля, так как
  /// [updateDisplayName] не триггерит стрим [authStateChanges].
  /// Перечитывает актуальные данные из Firebase Auth и обновляет [AppState].
  Future<void> _onUserRefreshRequested(
    AppUserRefreshRequested event,
    Emitter<AppState> emit,
  ) async {
    await _authRepository.reloadCurrentUser();
    final UserModel user = _authRepository.currentUser;
    if (user.isNotEmpty) {
      AppLogger.info('AppBloc: профиль обновлён — ${user.displayName}');
      emit(AppState.authenticated(user));
    }
  }

  /// Закрываем подписку при уничтожении BLoC.
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

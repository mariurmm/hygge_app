import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashLoading()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(
      Duration(seconds: AppConstants.splashDelaySeconds),
    );
    emit(
      AuthRepository.instance.isLoggedIn
          ? const SplashAuthenticated()
          : const SplashUnauthenticated(),
    );
  }
}
import 'package:bloc/bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const SplashLoading()) {
    on<SplashStarted>(_onStarted);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(SplashStarted event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDelaySeconds));
    emit(_authRepository.isLoggedIn ? const SplashAuthenticated() : const SplashUnauthenticated());
  }
}

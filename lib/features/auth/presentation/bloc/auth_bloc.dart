import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/types/api_result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _authRepository.login(event.email, event.password);

    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
      onError: (error) {
        error = error.copyWith(context: event.context);
        emit(AuthError(error.getLocalizedMessage()));
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final registerResult = await _authRepository.register(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    await registerResult.fold(
      onSuccess: (user) async {
        // Registration successful, now automatically login to get token
        final loginResult =
            await _authRepository.login(event.email, event.password);

        loginResult.fold(
          onSuccess: (authenticatedUser) =>
              emit(AuthAuthenticated(authenticatedUser)),
          onError: (loginError) {
            loginError = loginError.copyWith(context: event.context);
            emit(AuthError(
                'Registration successful but login failed: ${loginError.getLocalizedMessage()}'));
          },
        );
      },
      onError: (error) {
        error = error.copyWith(context: event.context);
        emit(AuthError(error.getLocalizedMessage()));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    if (_authRepository.getCurrentUser() == null) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthLoading());

    final result = await _authRepository.logout();

    if (result.isSuccess) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError(result.error?.message ?? 'Logout failed'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}

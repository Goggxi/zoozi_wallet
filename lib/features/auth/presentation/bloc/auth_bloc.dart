import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

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

    // Step 1: Register user
    final registerResult = await _authRepository.register(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    await registerResult.fold(
      onSuccess: (user) async {
        // Step 2: If register successful but no token, try auto-login
        if (user.token == null || user.token!.isEmpty) {
          // Auto-login to get token
          final loginResult =
              await _authRepository.login(event.email, event.password);

          loginResult.fold(
            onSuccess: (loggedInUser) {
              // Auto-login successful, go to home
              emit(AuthAuthenticated(loggedInUser));
            },
            onError: (error) {
              // Auto-login failed, redirect to login page
              emit(AuthRegisteredButNotLoggedIn(user.email));
            },
          );
        } else {
          // Register response includes token, proceed to home
          emit(AuthAuthenticated(user));
        }
      },
      onError: (error) {
        // Register failed
        error = error.copyWith(context: event.context);
        emit(AuthError(error.getLocalizedMessage()));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: Logout event received');

    if (_authRepository.getCurrentUser() == null) {
      debugPrint('AuthBloc: No user found, emitting AuthUnauthenticated');
      emit(AuthUnauthenticated());
      return;
    }

    debugPrint('AuthBloc: Starting logout process...');
    emit(AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      onSuccess: (_) {
        debugPrint('AuthBloc: Logout successful, emitting AuthUnauthenticated');
        emit(AuthUnauthenticated());
      },
      onError: (error) {
        debugPrint('AuthBloc: Logout failed with error: ${error.message}');
        emit(AuthError(error.message));
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('AuthBloc: Checking auth status...');
    final user = _authRepository.getCurrentUser();
    final isAuth = _authRepository.isAuthenticated;

    debugPrint('AuthBloc: User exists: ${user != null}');
    debugPrint('AuthBloc: Is authenticated: $isAuth');
    debugPrint(
        'AuthBloc: User token: ${user?.token != null ? 'exists' : 'missing'}');

    if (user != null && isAuth) {
      debugPrint('AuthBloc: Emitting AuthAuthenticated');
      emit(AuthAuthenticated(user));
    } else {
      debugPrint('AuthBloc: Emitting AuthUnauthenticated');
      emit(AuthUnauthenticated());
    }
  }
}

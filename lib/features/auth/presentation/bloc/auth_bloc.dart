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

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    result.fold(
      onSuccess: (user) => emit(AuthAuthenticated(user)),
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

    result.fold(
      onSuccess: (_) => emit(AuthUnauthenticated()),
      onError: (error) => emit(AuthError(error.message)),
    );
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

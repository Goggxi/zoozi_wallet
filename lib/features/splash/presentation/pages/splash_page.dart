import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/di/di.dart';
import 'package:zoozi_wallet/features/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authBloc = getIt<AuthBloc>();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _authBloc.add(CheckAuthStatusEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            l.appName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

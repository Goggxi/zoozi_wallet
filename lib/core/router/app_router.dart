import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:zoozi_wallet/di/di.dart';
import 'package:zoozi_wallet/features/auth/domain/repositories/auth_repository.dart';
import 'package:zoozi_wallet/features/auth/presentation/pages/login_page.dart';
import 'package:zoozi_wallet/features/auth/presentation/pages/register_page.dart';
import 'package:zoozi_wallet/features/home/presentation/pages/home_page.dart';
import 'package:zoozi_wallet/features/home/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:zoozi_wallet/features/settings/presentation/pages/settings_page.dart';
import 'package:zoozi_wallet/features/splash/presentation/pages/splash_page.dart';
import 'package:zoozi_wallet/features/wallet/presentation/pages/add_wallet_page.dart';
import 'package:zoozi_wallet/features/wallet/presentation/pages/transaction_page.dart';
import 'package:zoozi_wallet/features/wallet/presentation/pages/wallet_detail_page.dart';
import 'package:zoozi_wallet/features/wallet/presentation/pages/wallet_page.dart';

@lazySingleton
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String addWallet = 'add';
  static const String walletDetail = ':id';
  static const String transactions = '/transactions';
  static const String settings = '/settings';

  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  bool get isAuthenticated => _authRepository.isAuthenticated;

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.matchedLocation == login;
    final isRegistering = state.matchedLocation == register;
    final isSplash = state.matchedLocation == splash;

    // If not authenticated and not on auth pages or splash, go to login
    if (!isAuthenticated && !isLoggingIn && !isRegistering && !isSplash) {
      return login;
    }

    // If authenticated and on auth pages, go to home
    if (isAuthenticated && (isLoggingIn || isRegistering)) {
      return home;
    }

    return null;
  }

  late final _goRouter = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(
            currentIndex: navigationShell.currentIndex,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: wallet,
                name: 'wallet',
                builder: (context, state) => const WalletPage(),
                routes: [
                  GoRoute(
                    path: addWallet,
                    name: 'addWallet',
                    builder: (context, state) => const AddWalletPage(),
                  ),
                  GoRoute(
                    path: walletDetail,
                    name: 'walletDetail',
                    builder: (context, state) {
                      final walletId = state.pathParameters['id']!;
                      return WalletDetailPage(walletId: walletId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: transactions,
                name: 'transactions',
                builder: (context, state) => const TransactionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  GoRouter get router => _goRouter;
}

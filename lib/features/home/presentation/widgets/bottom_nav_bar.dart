import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRouter.home);
            break;
          case 1:
            context.go(AppRouter.wallet);
            break;
          case 2:
            context.go(AppRouter.transactions);
            break;
          case 3:
            context.go(AppRouter.settings);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        NavigationDestination(
          icon: Icon(Icons.swap_horiz_outlined),
          selectedIcon: Icon(Icons.swap_horiz),
          label: 'Transactions',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

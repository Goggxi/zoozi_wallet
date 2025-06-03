import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B4D), // Dark purple background
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.camera_outdoor_rounded,
            selectedIcon: Icons.camera_outdoor,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.wallet_outlined,
            selectedIcon: Icons.wallet,
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.camera_outlined,
            selectedIcon: Icons.camera,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? Colors.white : Colors.white.withAlpha(100),
          size: 24,
        ),
      ),
    );
  }
}

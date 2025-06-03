import 'package:flutter/material.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(l.settings),
        centerTitle: true,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingItem(
                  icon: Icons.palette_outlined,
                  title: l.theme,
                  onTap: () {
                    // TODO: Navigate to theme settings
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: l.language,
                  onTap: () {
                    // TODO: Navigate to language settings
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: l.about,
                  onTap: () {
                    // TODO: Navigate to about page
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Handle logout
                },
                icon: const Icon(Icons.logout),
                label: Text(
                  l.logout,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  side: const BorderSide(
                    color: AppColors.purple,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

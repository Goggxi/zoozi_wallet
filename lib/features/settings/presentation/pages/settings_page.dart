import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoozi_wallet/core/theme/app_theme.dart';
import 'package:zoozi_wallet/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:zoozi_wallet/features/settings/presentation/bloc/theme_state.dart';
import '../widgets/theme_switch_dialog.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final themeBloc = context.read<ThemeBloc>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    if (state is ThemeLoaded) {
                      return _buildSettingItem(
                        context: context,
                        icon: Icons.palette_outlined,
                        title: l.theme,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.themeType == ThemeType.light
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.themeType == ThemeType.light
                                  ? l.light
                                  : l.dark,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ThemeSwitchDialog(
                              themeBloc: themeBloc,
                            ),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  context: context,
                  icon: Icons.language_outlined,
                  title: l.language,
                  onTap: () {
                    // TODO: Navigate to language settings
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  context: context,
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
                icon: Icon(
                  Icons.logout,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  l.logout,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.errorContainer.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  side: BorderSide(
                    color: theme.colorScheme.error,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}

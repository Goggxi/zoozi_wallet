import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/theme/app_theme.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/di/di.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';
import '../widgets/theme_switch_dialog.dart';
import '../widgets/language_switch_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final themeBloc = getIt<ThemeBloc>();
    final languageBloc = getIt<LanguageBloc>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  bloc: themeBloc,
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
                BlocBuilder<LanguageBloc, LanguageState>(
                  bloc: languageBloc,
                  builder: (context, state) {
                    if (state is LanguageLoaded) {
                      return _buildSettingItem(
                        context: context,
                        icon: Icons.language_outlined,
                        title: l.language,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.locale.languageCode.toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => LanguageSwitchDialog(
                              languageBloc: languageBloc,
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
                  _showLogoutConfirmationDialog(context);
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
                      theme.colorScheme.errorContainer.withAlpha(25),
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
              color: theme.shadowColor.withAlpha(50),
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
                color: theme.colorScheme.primaryContainer.withAlpha(50),
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
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final authBloc = getIt<AuthBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Logout',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout from your account?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to login again to access your wallet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocListener<AuthBloc, AuthState>(
                  bloc: authBloc,
                  listener: (context, state) {
                    if (state is AuthUnauthenticated) {
                      Navigator.of(context).pop(); // Close dialog
                      context.go(AppRouter.login); // Navigate to login
                    } else if (state is AuthError) {
                      Navigator.of(context).pop(); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout failed: ${state.message}'),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    bloc: authBloc,
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                authBloc.add(LogoutEvent());
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(l.logout),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

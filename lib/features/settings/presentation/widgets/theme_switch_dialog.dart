import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class ThemeSwitchDialog extends StatelessWidget {
  final ThemeBloc themeBloc;

  const ThemeSwitchDialog({super.key, required this.themeBloc});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      bloc: themeBloc,
      builder: (context, state) {
        if (state is ThemeLoaded) {
          final currentTheme = state.themeType;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.chooseTheme,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ThemeOption(
                      title: l.light,
                      icon: Icons.light_mode_rounded,
                      isSelected: currentTheme == ThemeType.light,
                      onTap: () {
                        if (currentTheme != ThemeType.light) {
                          themeBloc.add(ToggleTheme(currentTheme));
                        }
                        Navigator.pop(context);
                      },
                      theme: theme,
                    ),
                    _ThemeOption(
                      title: l.dark,
                      icon: Icons.dark_mode_rounded,
                      isSelected: currentTheme == ThemeType.dark,
                      onTap: () {
                        if (currentTheme != ThemeType.dark) {
                          themeBloc.add(ToggleTheme(currentTheme));
                        }
                        Navigator.pop(context);
                      },
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';

class LanguageSwitchDialog extends StatelessWidget {
  final LanguageBloc languageBloc;

  const LanguageSwitchDialog({super.key, required this.languageBloc});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: languageBloc,
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final currentLocale = state.locale;
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
                  l.chooseLanguage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LanguageOption(
                      title: l.english,
                      languageCode: 'en',
                      isSelected: currentLocale.languageCode == 'en',
                      onTap: () {
                        if (currentLocale.languageCode != 'en') {
                          languageBloc.add(
                            ChangeLanguage(
                              currentLocale: currentLocale,
                              newLocale: const Locale('en'),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                      theme: theme,
                    ),
                    _LanguageOption(
                      title: l.indonesian,
                      languageCode: 'id',
                      isSelected: currentLocale.languageCode == 'id',
                      onTap: () {
                        if (currentLocale.languageCode != 'id') {
                          languageBloc.add(
                            ChangeLanguage(
                              currentLocale: currentLocale,
                              newLocale: const Locale('id'),
                            ),
                          );
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

class _LanguageOption extends StatelessWidget {
  final String title;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LanguageOption({
    required this.title,
    required this.languageCode,
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
          color: isSelected ? theme.colorScheme.primary.withAlpha(25) : null,
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
            Text(
              languageCode.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
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

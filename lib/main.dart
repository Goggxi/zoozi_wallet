import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'features/settings/presentation/bloc/theme_event.dart';
import 'features/settings/presentation/bloc/theme_state.dart';
import 'features/settings/presentation/bloc/language_bloc.dart';
import 'features/settings/presentation/bloc/language_event.dart';
import 'features/settings/presentation/bloc/language_state.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/di/di.dart';
import 'package:zoozi_wallet/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Initialize theme bloc
  getIt<ThemeBloc>().add(LoadTheme());

  // Initialize language bloc
  getIt<LanguageBloc>().add(LoadLanguage());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      bloc: getIt<ThemeBloc>(),
      builder: (context, state) {
        final themeData = state is ThemeLoaded
            ? (state.themeType == ThemeType.light
                ? AppTheme.light
                : AppTheme.dark)
            : AppTheme.light;

        return BlocBuilder<LanguageBloc, LanguageState>(
            bloc: getIt<LanguageBloc>(),
            builder: (context, languageState) {
              return MaterialApp.router(
                title: 'Zoozi Wallet',
                theme: themeData,
                routerConfig: getIt<AppRouter>().router,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languageState is LanguageLoaded
                    ? languageState.locale
                    : null,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    behavior: HitTestBehavior.translucent,
                    child: child!,
                  );
                },
              );
            });
      },
    );
  }
}

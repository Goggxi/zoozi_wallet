import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:zoozi_wallet/core/theme/app_theme.dart';
import '../../domain/repositories/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      emit(ThemeLoading());
      final theme = await _themeRepository.getTheme();
      emit(ThemeLoaded(theme));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    try {
      final newTheme = event.currentTheme == ThemeType.light
          ? ThemeType.dark
          : ThemeType.light;
      await _themeRepository.setTheme(newTheme);
      emit(ThemeLoaded(newTheme));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
}

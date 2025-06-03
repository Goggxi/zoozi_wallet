import 'package:equatable/equatable.dart';
import '../../../../core/theme/app_theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {
  final ThemeType currentTheme;

  const ToggleTheme(this.currentTheme);

  @override
  List<Object> get props => [currentTheme];
}

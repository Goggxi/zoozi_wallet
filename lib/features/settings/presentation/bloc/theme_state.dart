import 'package:equatable/equatable.dart';
import '../../../../core/theme/app_theme.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeType themeType;

  const ThemeLoaded(this.themeType);

  @override
  List<Object> get props => [themeType];
}

class ThemeError extends ThemeState {
  final String message;

  const ThemeError(this.message);

  @override
  List<Object> get props => [message];
} 
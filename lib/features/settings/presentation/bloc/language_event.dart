import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LoadLanguage extends LanguageEvent {}

class ChangeLanguage extends LanguageEvent {
  final Locale currentLocale;
  final Locale newLocale;

  const ChangeLanguage({
    required this.currentLocale,
    required this.newLocale,
  });

  @override
  List<Object> get props => [currentLocale, newLocale];
}

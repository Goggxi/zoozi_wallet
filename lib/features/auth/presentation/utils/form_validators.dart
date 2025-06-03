import 'package:flutter/material.dart';
import 'package:zoozi_wallet/l10n/app_localizations.dart';

class FormValidators {
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context).invalidEmail;
    }

    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).passwordRequired;
    }

    if (value.length < 8) {
      return AppLocalizations.of(context).passwordLength;
    }

    return null;
  }

  static String? validateName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).nameRequired;
    }

    if (value.length < 3) {
      return AppLocalizations.of(context).nameLength;
    }

    return null;
  }

  static String? validateConfirmPassword(
      String? value, String password, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).confirmPasswordRequired;
    }

    if (value != password) {
      return AppLocalizations.of(context).passwordsDoNotMatch;
    }

    return null;
  }
}

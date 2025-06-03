import 'package:flutter/material.dart';
import 'package:zoozi_wallet/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

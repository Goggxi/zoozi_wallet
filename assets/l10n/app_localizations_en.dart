// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get changeLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get indonesia => 'Indonesia';

  @override
  String language(String type) {
    return '$type Language';
  }

  @override
  String get ok => 'OK';

  @override
  String get title => 'Zoozi Wallet';

  @override
  String get tryAgain => 'Try Again';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get changeLanguage => 'Pilih Bahasa';

  @override
  String get english => 'Inggris';

  @override
  String get indonesia => 'Indonesia';

  @override
  String language(String type) {
    return 'Bahasa $type';
  }

  @override
  String get ok => 'Oke';

  @override
  String get title => 'Zoozi Wallet';

  @override
  String get tryAgain => 'Coba Lagi';
}

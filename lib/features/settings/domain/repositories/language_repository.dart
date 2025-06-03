import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:zoozi_wallet/core/storage/local_storage.dart';

abstract class ILanguageRepository {
  Future<Locale> getLanguage();
  Future<void> setLanguage(Locale locale);
}

@Injectable(as: ILanguageRepository)
class LanguageRepository implements ILanguageRepository {
  final ILocalStorage _localStorage;

  static const String _languageKey = 'app_language';

  LanguageRepository(this._localStorage);

  @override
  Future<Locale> getLanguage() async {
    final languageCode = _localStorage.getString(_languageKey);
    return Locale(languageCode ?? 'en');
  }

  @override
  Future<void> setLanguage(Locale locale) async {
    await _localStorage.saveString(_languageKey, locale.languageCode);
  }
}

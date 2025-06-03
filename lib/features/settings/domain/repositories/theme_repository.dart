import 'package:injectable/injectable.dart';
import 'package:zoozi_wallet/core/storage/local_storage.dart';
import 'package:zoozi_wallet/core/theme/app_theme.dart';

abstract class IThemeRepository {
  Future<ThemeType> getTheme();
  Future<void> setTheme(ThemeType theme);
}

@Injectable(as: IThemeRepository)
class ThemeRepository implements IThemeRepository {
  final ILocalStorage _localStorage;

  static const String _themeKey = 'app_theme';

  ThemeRepository(this._localStorage);

  @override
  Future<ThemeType> getTheme() async {
    final themeString = _localStorage.getString(_themeKey);
    return themeString == ThemeType.dark.name
        ? ThemeType.dark
        : ThemeType.light;
  }

  @override
  Future<void> setTheme(ThemeType theme) async {
    await _localStorage.saveString(_themeKey, theme.name);
  }
}

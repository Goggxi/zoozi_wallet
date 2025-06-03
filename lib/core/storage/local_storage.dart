import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/exceptions/cache_exception.dart';

/// Abstract class defining local storage operations
abstract class ILocalStorage {
  Future<bool> saveString(String key, String value);
  Future<bool> saveBool(String key, bool value);
  Future<bool> saveInt(String key, int value);
  Future<bool> saveDouble(String key, double value);
  Future<bool> saveStringList(String key, List<String> value);
  Future<bool> saveJson(String key, Map<String, dynamic> json);

  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  double? getDouble(String key);
  List<String>? getStringList(String key);
  Map<String, dynamic>? getJson(String key);

  Future<bool> remove(String key);
  Future<bool> clear();
  bool hasKey(String key);
}

@Singleton(as: ILocalStorage)
class LocalStorage implements ILocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  @override
  Future<bool> saveString(String key, String value) {
    try {
      return _prefs.setString(key, value);
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  Future<bool> saveBool(String key, bool value) {
    try {
      return _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  Future<bool> saveInt(String key, int value) {
    try {
      return _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  Future<bool> saveDouble(String key, double value) {
    try {
      return _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  Future<bool> saveStringList(String key, List<String> value) {
    try {
      return _prefs.setStringList(key, value);
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  Future<bool> saveJson(String key, Map<String, dynamic> json) {
    try {
      return _prefs.setString(key, jsonEncode(json));
    } catch (e) {
      throw CacheException.write(key, e);
    }
  }

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException.read(key, e);
    }
  }

  @override
  Future<bool> remove(String key) {
    try {
      return _prefs.remove(key);
    } catch (e) {
      throw CacheException.delete(key, e);
    }
  }

  @override
  Future<bool> clear() {
    try {
      return _prefs.clear();
    } catch (e) {
      throw CacheException(
        message: 'cache_clear_error',
        error: e,
        key: 'all',
      );
    }
  }

  @override
  bool hasKey(String key) => _prefs.containsKey(key);
}

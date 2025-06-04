import 'package:injectable/injectable.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger/app_logger.dart';
import '../models/auth_model.dart';

abstract class IAuthLocalDataSource {
  Future<bool> saveToken(String token);
  String? getToken();
  Future<bool> saveUser(AuthModel user);
  AuthModel? getUser();
  Future<bool> clearAuth();
  bool get isAuthenticated;
}

@Injectable(as: IAuthLocalDataSource)
class AuthLocalDataSource implements IAuthLocalDataSource {
  final ILocalStorage _localStorage;
  final IAppLogger _logger;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthLocalDataSource(this._localStorage, this._logger);

  @override
  Future<bool> saveToken(String token) async {
    _logger.debug('Saving auth token');
    try {
      final result = await _localStorage.saveString(_tokenKey, token);
      _logger.debug('Auth token saved successfully');
      return result;
    } catch (e) {
      _logger.error('Failed to save auth token', e);
      rethrow;
    }
  }

  @override
  String? getToken() {
    try {
      final token = _localStorage.getString(_tokenKey);
      _logger.debug(
          'Retrieved auth token: ${token != null ? 'found' : 'not found'}');
      return token;
    } catch (e) {
      _logger.error('Failed to get auth token', e);
      rethrow;
    }
  }

  @override
  Future<bool> saveUser(AuthModel user) async {
    _logger.debug('Saving user data: ${user.email}');
    try {
      final result = await _localStorage.saveJson(_userKey, user.toJson());
      _logger.debug('User data saved successfully');
      return result;
    } catch (e) {
      _logger.error('Failed to save user data', e);
      rethrow;
    }
  }

  @override
  AuthModel? getUser() {
    try {
      final userData = _localStorage.getJson(_userKey);
      if (userData == null) {
        _logger.debug('No user data found');
        return null;
      }
      _logger.debug('Retrieved user data');
      return AuthModel.fromJson(userData);
    } catch (e) {
      _logger.error('Failed to get user data', e);
      rethrow;
    }
  }

  @override
  Future<bool> clearAuth() async {
    _logger.debug('Clearing auth data');
    try {
      await _localStorage.remove(_tokenKey);
      final result = await _localStorage.remove(_userKey);
      _logger.debug('Auth data cleared successfully');
      return result;
    } catch (e) {
      _logger.error('Failed to clear auth data', e);
      rethrow;
    }
  }

  @override
  bool get isAuthenticated {
    try {
      final token = _localStorage.getString(_tokenKey);
      final hasValidToken = token != null && token.isNotEmpty;
      _logger.debug(
          'Auth status: ${hasValidToken ? 'authenticated' : 'not authenticated'} (token: ${token != null ? 'exists' : 'missing'})');
      return hasValidToken;
    } catch (e) {
      _logger.error('Failed to check auth status', e);
      return false; // Default to not authenticated on error
    }
  }
}

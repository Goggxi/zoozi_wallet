import 'package:injectable/injectable.dart';

import '../../../../core/utils/exceptions/api_exception.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_model.dart';

abstract class IAuthRepository {
  Future<(ApiException?, AuthModel?)> login(String email, String password);
  Future<(ApiException?, AuthModel?)> register({
    required String email,
    required String password,
    String? name,
  });
  Future<(ApiException?, void)> logout();
  AuthModel? getCurrentUser();
  bool get isAuthenticated;
}

@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepository(this._remoteDataSource, this._localDataSource);

  @override
  Future<(ApiException?, AuthModel?)> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.login(email, password);
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);
      return (null, user);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, AuthModel?)> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);
      return (null, user);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, void)> logout() async {
    try {
      await _localDataSource.clearAuth();
      return (null, null);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  AuthModel? getCurrentUser() {
    return _localDataSource.getUser();
  }

  @override
  bool get isAuthenticated => _localDataSource.isAuthenticated;
}

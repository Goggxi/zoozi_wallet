import 'package:injectable/injectable.dart';

import '../../../../core/utils/exceptions/api_exception.dart';
import '../../../../core/utils/types/api_result.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_model.dart';

abstract class IAuthRepository {
  Future<ApiResult<AuthModel>> login(String email, String password);
  Future<ApiResult<AuthModel>> register({
    required String email,
    required String password,
    String? name,
  });
  Future<ApiResult<void>> logout();
  AuthModel? getCurrentUser();
  bool get isAuthenticated;
}

@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepository(this._remoteDataSource, this._localDataSource);

  @override
  Future<ApiResult<AuthModel>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.login(email, password);
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);
      return Success(user);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<AuthModel>> register({
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
      return Success(user);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _localDataSource.clearAuth();
      return (error: null, data: null);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  AuthModel? getCurrentUser() {
    return _localDataSource.getUser();
  }

  @override
  bool get isAuthenticated => _localDataSource.isAuthenticated;
}

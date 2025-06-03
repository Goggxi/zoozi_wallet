import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/utils/logger/app_logger.dart';
import '../../../../core/utils/network/http_client.dart';
import '../models/auth_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> register({
    required String email,
    required String password,
    String? name,
  });
}

@Injectable(as: IAuthRemoteDataSource)
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final HttpClient _client;
  final IAppLogger _logger;
  final String baseUrl;

  AuthRemoteDataSource(this._client, this._logger)
      : baseUrl = const String.fromEnvironment('BASE_URL');

  @override
  Future<AuthModel> login(String email, String password) async {
    _logger.info('Logging in user: $email');

    final request = LoginRequest(email: email, password: password);

    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/auth/login',
      body: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    _logger.info('User logged in successfully: $email');

    // Since login response only contains token, we create a minimal user model
    return AuthModel(
      id: -1, // We don't get the ID from login response
      email: email,
      accessToken: loginResponse.accessToken,
    );
  }

  @override
  Future<AuthModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    _logger.info('Registering new user: $email');

    final request = RegisterRequest(
      email: email,
      password: password,
      name: name,
    );

    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/auth/register',
      body: request.toJson(),
    );

    final user = AuthModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    _logger.info('User registered successfully: $email');

    return user;
  }
}

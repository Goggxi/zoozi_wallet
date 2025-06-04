import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../di/di.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../exceptions/api_exception.dart';
import '../logger/app_logger.dart';

enum RequestMethod { get, post, put, delete }

@injectable
class HttpClient {
  final http.Client _client;
  final IAppLogger _logger;
  final IAuthLocalDataSource _authLocalDataSource;

  HttpClient(
    this._client,
    this._logger,
    this._authLocalDataSource,
  );

  Future<http.Response> apiRequest({
    required String url,
    required RequestMethod method,
    required String apiPath,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      var uri = Uri.parse('$url$apiPath');

      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(
          queryParameters: queryParameters.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Add authentication token if available
      final token = _authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
        _logger.debug('Added auth token to request headers');
      } else {
        _logger.debug('No auth token available for request');
      }

      http.Response response;
      final requestBody = body != null ? jsonEncode(body) : null;

      _logger.debug('API Request: ${method.name.toUpperCase()} $uri');
      if (body != null) {
        _logger.debug('Request Body: $body');
      }
      _logger.debug('Request Headers: ${requestHeaders.keys.toList()}');
      if (queryParameters != null) {
        _logger.debug('Query Parameters: $queryParameters');
      }

      switch (method) {
        case RequestMethod.get:
          response =
              await _client.get(uri, headers: requestHeaders).timeout(timeout);
          break;
        case RequestMethod.post:
          response = await _client
              .post(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        case RequestMethod.put:
          response = await _client
              .put(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
        case RequestMethod.delete:
          response = await _client
              .delete(uri, headers: requestHeaders, body: requestBody)
              .timeout(timeout);
          break;
      }

      _logger.network(
        method.name.toUpperCase(),
        uri.toString(),
        requestBody,
        requestHeaders,
        response.body,
        response.statusCode,
      );

      _logger.debug(
          'API Response: ${response.statusCode} - ${response.body.length} bytes');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      // Handle 401 Unauthorized with better logic
      if (response.statusCode == 401) {
        await _handleUnauthorized(apiPath);
      }

      throw _handleErrorResponse(response);
    } on TimeoutException catch (e) {
      _logger.error('Request timeout', e);
      throw ApiException.timeout();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      _logger.error('Network error', e);
      throw ApiException.network(e);
    }
  }

  Future<void> _handleUnauthorized(String apiPath) async {
    _logger.warning('Received 401 Unauthorized for: $apiPath');

    // Only trigger logout for non-auth endpoints and avoid aggressive logout
    if (!apiPath.contains('/auth/')) {
      _logger.debug('Clearing auth data due to 401 on protected endpoint');

      // Check if this is during app initialization by checking if user is still logged in
      final currentUser = _authLocalDataSource.getUser();
      final currentToken = _authLocalDataSource.getToken();

      if (currentUser == null || currentToken == null) {
        _logger.debug('User already logged out, skipping additional logout');
        return;
      }

      // Clear auth data first
      await _authLocalDataSource.clearAuth();

      // Add delay to prevent immediate logout during app initialization
      await Future.delayed(const Duration(milliseconds: 1000));

      // Double-check if the user hasn't been re-authenticated during the delay
      final tokenAfterDelay = _authLocalDataSource.getToken();
      final userAfterDelay = _authLocalDataSource.getUser();

      // Only trigger logout if auth is still cleared and no new login occurred
      if (tokenAfterDelay == null && userAfterDelay == null) {
        _logger.debug('Triggering logout event after 401');
        try {
          final authBloc = getIt<AuthBloc>();
          // Check if the bloc is in a state that can handle logout
          if (authBloc.state is! AuthLoading) {
            authBloc.add(LogoutEvent());
          }
        } catch (e) {
          _logger.error('Failed to trigger logout after 401', e);
        }
      } else {
        _logger.debug('User re-authenticated during delay, skipping logout');
      }
    } else {
      _logger.debug('401 on auth endpoint - not triggering automatic logout');
    }
  }

  ApiException _handleErrorResponse(http.Response response) {
    final parsedJson = _tryParseJson(response.body);

    switch (response.statusCode) {
      case 400:
        return parsedJson != null
            ? ApiException.badRequest(parsedJson)
            : ApiException.badRequest({'message': response.body});
      case 401:
        return ApiException.unauthorized();
      case 403:
        return ApiException.forbidden();
      case 404:
        return ApiException.notFound();
      case 422:
        return parsedJson != null
            ? ApiException.validation(parsedJson)
            : ApiException.validation({'message': response.body});
      case 500:
      default:
        return ApiException.server();
    }
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

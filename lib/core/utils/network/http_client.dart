import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../exceptions/api_exception.dart';
import '../logger/app_logger.dart';

enum RequestMethod { get, post, put, delete }

@injectable
class HttpClient {
  final http.Client _client;
  final IAppLogger _logger;

  HttpClient(this._client, this._logger);

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

      http.Response response;
      final requestBody = body != null ? jsonEncode(body) : null;

      _logger.debug('API Request: ${method.name.toUpperCase()} $uri');
      if (body != null) {
        _logger.debug('Request Body: $body');
      }
      if (headers != null) {
        _logger.debug('Request Headers: $headers');
      }
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
        response.body,
        response.statusCode,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
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

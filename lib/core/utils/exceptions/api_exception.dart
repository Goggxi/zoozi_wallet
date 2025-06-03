import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Custom exception class for handling API errors
class ApiException extends Equatable implements Exception {
  final String message;
  final int statusCode;
  final String errorType;
  final dynamic response;
  final List<String>? validationMessages;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.errorType,
    this.response,
    this.validationMessages,
  });

  /// Factory constructor for creating ApiException from HTTP response
  factory ApiException.fromResponse(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(
        message: json['message'] ?? 'Unknown error',
        statusCode: statusCode,
        errorType: json['error'] ?? 'unknown',
        response: json,
        validationMessages: json['message'] is List
            ? (json['message'] as List).cast<String>()
            : json['message'] is String
                ? [json['message'] as String]
                : null,
      );
    } catch (e) {
      return ApiException(
        message: body,
        statusCode: statusCode,
        errorType: 'unknown',
      );
    }
  }

  /// Factory constructor for network errors
  factory ApiException.network(dynamic error) {
    return ApiException(
      message: 'Network error: ${error.toString()}',
      statusCode: -1,
      errorType: 'network',
    );
  }

  /// Factory constructor for timeout errors
  factory ApiException.timeout() {
    return const ApiException(
      message: 'Request timeout',
      statusCode: -1,
      errorType: 'timeout',
    );
  }

  /// Factory constructor for server errors (5xx)
  factory ApiException.server() {
    return const ApiException(
      message: 'Internal server error',
      statusCode: 500,
      errorType: 'server_error',
    );
  }

  /// Factory constructor for unauthorized errors (401)
  factory ApiException.unauthorized() {
    return const ApiException(
      message: 'Unauthorized access',
      statusCode: 401,
      errorType: 'unauthorized',
    );
  }

  /// Factory constructor for forbidden errors (403)
  factory ApiException.forbidden() {
    return const ApiException(
      message: 'Access forbidden',
      statusCode: 403,
      errorType: 'forbidden',
    );
  }

  /// Factory constructor for not found errors (404)
  factory ApiException.notFound() {
    return const ApiException(
      message: 'Resource not found',
      statusCode: 404,
      errorType: 'not_found',
    );
  }

  /// Factory constructor for bad request errors (400)
  factory ApiException.badRequest(dynamic response) {
    if (response is Map<String, dynamic>) {
      return ApiException.fromResponse(jsonEncode(response), 400);
    }
    return ApiException(
      message: 'Bad request',
      statusCode: 400,
      errorType: 'bad_request',
      response: response,
    );
  }

  /// Factory constructor for validation errors
  factory ApiException.validation(Map<String, dynamic> errors) {
    return ApiException(
      message: 'Validation failed',
      statusCode: 422,
      errorType: 'validation',
      response: errors,
    );
  }

  /// Helper method to check if error is network related
  bool get isNetworkError => statusCode == -1 && errorType == 'network';

  /// Helper method to check if error is timeout
  bool get isTimeout => statusCode == -1 && errorType == 'timeout';

  /// Helper method to check if error is server error
  bool get isServerError => statusCode >= 500;

  /// Helper method to check if error is client error
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Helper method to check if error is unauthorized
  bool get isUnauthorized => statusCode == 401;

  /// Helper method to check if error is forbidden
  bool get isForbidden => statusCode == 403;

  /// Helper method to check if error is not found
  bool get isNotFound => statusCode == 404;

  /// Helper method to check if error is validation error
  bool get isValidationError => statusCode == 422;

  /// Helper method to check if error is bad request
  bool get isBadRequest => statusCode == 400;

  /// Get validation errors if available
  Map<String, dynamic>? get validationErrors {
    if (isValidationError && response is Map<String, dynamic>) {
      return response['errors'] as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode, Type: $errorType)';
  }

  @override
  List<Object?> get props => [
        message,
        statusCode,
        errorType,
        response,
        validationMessages,
      ];
}

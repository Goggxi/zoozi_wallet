import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:zoozi_wallet/l10n/app_localizations.dart';

/// Custom exception class for handling API errors
class ApiException extends Equatable implements Exception {
  final String message;
  final int statusCode;
  final String errorType;
  final dynamic response;
  final List<String>? validationMessages;
  final BuildContext? context;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.errorType,
    this.response,
    this.validationMessages,
    this.context,
  });

  /// Factory constructor for creating ApiException from HTTP response
  factory ApiException.fromResponse(String body, int statusCode,
      [BuildContext? context]) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(
        message: json['message'] ?? 'unknown_error',
        statusCode: statusCode,
        errorType: json['error'] ?? 'unknown',
        response: json,
        validationMessages: json['message'] is List
            ? (json['message'] as List).cast<String>()
            : json['message'] is String
                ? [json['message'] as String]
                : null,
        context: context,
      );
    } catch (e) {
      return ApiException(
        message: body,
        statusCode: statusCode,
        errorType: 'unknown',
        context: context,
      );
    }
  }

  /// Factory constructor for network errors
  factory ApiException.network(dynamic error, [BuildContext? context]) {
    return ApiException(
      message: 'network_error',
      statusCode: -1,
      errorType: 'network',
      response: error.toString(),
      context: context,
    );
  }

  /// Factory constructor for timeout errors
  factory ApiException.timeout([BuildContext? context]) {
    return ApiException(
      message: 'request_timeout',
      statusCode: -1,
      errorType: 'timeout',
      context: context,
    );
  }

  /// Factory constructor for server errors (5xx)
  factory ApiException.server([BuildContext? context]) {
    return ApiException(
      message: 'internal_server_error',
      statusCode: 500,
      errorType: 'server_error',
      context: context,
    );
  }

  /// Factory constructor for unauthorized errors (401)
  factory ApiException.unauthorized([BuildContext? context]) {
    return ApiException(
      message: 'unauthorized_error',
      statusCode: 401,
      errorType: 'unauthorized',
      context: context,
    );
  }

  /// Factory constructor for forbidden errors (403)
  factory ApiException.forbidden([BuildContext? context]) {
    return ApiException(
      message: 'forbidden_error',
      statusCode: 403,
      errorType: 'forbidden',
      context: context,
    );
  }

  /// Factory constructor for not found errors (404)
  factory ApiException.notFound([BuildContext? context]) {
    return ApiException(
      message: 'not_found_error',
      statusCode: 404,
      errorType: 'not_found',
      context: context,
    );
  }

  /// Factory constructor for bad request errors (400)
  factory ApiException.badRequest(dynamic response, [BuildContext? context]) {
    if (response is Map<String, dynamic>) {
      return ApiException.fromResponse(jsonEncode(response), 400, context);
    }
    return ApiException(
      message: 'bad_request_error',
      statusCode: 400,
      errorType: 'bad_request',
      response: response,
      context: context,
    );
  }

  /// Factory constructor for validation errors
  factory ApiException.validation(Map<String, dynamic> errors,
      [BuildContext? context]) {
    return ApiException(
      message: 'validation_error',
      statusCode: 422,
      errorType: 'validation',
      response: errors,
      context: context,
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

  String getLocalizedMessage() {
    if (context != null) {
      final l10n = AppLocalizations.of(context!);

      // Handle validation errors first
      if (isValidationError && validationMessages != null) {
        return _handleValidationErrors(l10n, validationMessages!);
      }

      // Handle specific error types
      switch (message) {
        case 'network_error':
          return l10n.networkError;
        case 'request_timeout':
          return l10n.requestTimeout;
        case 'internal_server_error':
          return l10n.internalServerError;
        case 'unauthorized_error':
          return l10n.unauthorizedError;
        case 'forbidden_error':
          return l10n.forbiddenError;
        case 'not_found_error':
          return l10n.notFoundError;
        case 'bad_request_error':
          return l10n.badRequestError;
        case 'validation_error':
          return l10n.validationError;
        default:
          if (response != null) {
            return _mapBadRequestError(l10n, response.toString());
          }
          return l10n.unknownError;
      }
    }
    return toString();
  }

  String _handleValidationErrors(AppLocalizations l10n, List<String> errors) {
    // Map specific validation errors
    for (final error in errors) {
      if (error.contains('password must be longer')) {
        return l10n.passwordLengthError;
      }
      if (error.contains('password should not be empty')) {
        return l10n.passwordRequired;
      }
      if (error.contains('password must be a string')) {
        return l10n.passwordTypeError;
      }
      if (error.contains('currency must be one')) {
        return l10n.invalidCurrencyError;
      }
      if (error.contains('amount must be a positive number') ||
          error.contains('amount must be a number')) {
        return l10n.amountValidationError;
      }
    }

    // If no specific mapping found, return the first error
    return errors.first;
  }

  String _mapBadRequestError(AppLocalizations l10n, String message) {
    if (message.contains('Invalid credentials')) {
      return l10n.invalidCredentialsError;
    }
    if (message.contains('Expected double-quoted property name in JSON')) {
      return l10n.invalidJsonError;
    }

    return message;
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

  /// Creates a copy of this ApiException with the given fields replaced with the new values.
  ApiException copyWith({
    String? message,
    int? statusCode,
    String? errorType,
    dynamic response,
    List<String>? validationMessages,
    BuildContext? context,
  }) {
    return ApiException(
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      errorType: errorType ?? this.errorType,
      response: response ?? this.response,
      validationMessages: validationMessages ?? this.validationMessages,
      context: context ?? this.context,
    );
  }
}

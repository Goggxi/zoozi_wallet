import 'package:flutter/material.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';

import '../exceptions/api_exception.dart';
import '../exceptions/cache_exception.dart';

class ErrorMapper {
  static String mapErrorMessage(BuildContext context, dynamic error) {
    final l = context.l10n;

    // Handle ApiException
    if (error is ApiException) {
      return _mapApiException(context, error);
    }

    // Handle CacheException
    if (error is CacheException) {
      return _mapCacheException(context, error);
    }

    // Handle Map errors (legacy support)
    if (error is Map<String, dynamic>) {
      return _mapLegacyError(context, error);
    }

    // Handle string errors
    if (error is String) {
      return _mapStringError(context, error);
    }

    return l.unknownError;
  }

  static String _mapApiException(BuildContext context, ApiException error) {
    return error.getLocalizedMessage();
  }

  static String _mapCacheException(BuildContext context, CacheException error) {
    return error.getLocalizedMessage();
  }

  static String _mapLegacyError(
      BuildContext context, Map<String, dynamic> error) {
    final l = context.l10n;
    final statusCode = error['statusCode'] as int?;
    final message = error['message'];

    switch (statusCode) {
      case 400:
        if (message is List) {
          return _handleValidationErrors(context, message.cast<String>());
        }
        return _mapBadRequestError(context, message.toString());
      case 401:
        return l.unauthorizedError;
      case 403:
        return l.forbiddenError;
      case 404:
        return l.notFoundError;
      case 500:
        return l.internalServerError;
      default:
        return l.unknownError;
    }
  }

  static String _mapStringError(BuildContext context, String error) {
    final l = context.l10n;

    if (error.contains('network')) {
      return l.networkError;
    }
    if (error.contains('timeout')) {
      return l.requestTimeout;
    }
    if (error.contains('validation')) {
      return l.validationError;
    }

    return error;
  }

  static String _handleValidationErrors(
    BuildContext context,
    List<String> errors,
  ) {
    final l = context.l10n;

    // Map specific validation errors
    for (final error in errors) {
      if (error.contains('password must be longer')) {
        return l.passwordLengthError;
      }
      if (error.contains('password should not be empty')) {
        return l.passwordRequired;
      }
      if (error.contains('password must be a string')) {
        return l.passwordTypeError;
      }
      if (error.contains('currency must be one')) {
        return l.invalidCurrencyError;
      }
      if (error.contains('amount must be a positive number') ||
          error.contains('amount must be a number')) {
        return l.amountValidationError;
      }
    }

    // If no specific mapping found, return the first error
    return errors.first;
  }

  static String _mapBadRequestError(BuildContext context, String message) {
    final l = context.l10n;

    if (message.contains('Invalid credentials')) {
      return l.invalidCredentialsError;
    }
    if (message.contains('Expected double-quoted property name in JSON')) {
      return l.invalidJsonError;
    }

    return message;
  }
}

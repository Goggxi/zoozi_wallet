import 'package:flutter/material.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';

class ErrorMapper {
  static String mapErrorMessage(BuildContext context, dynamic error) {
    final l = context.l10n;

    if (error is Map<String, dynamic>) {
      final statusCode = error['statusCode'] as int?;
      final message = error['message'];

      switch (statusCode) {
        case 400:
          if (message is List) {
            // Handle validation errors
            return _handleValidationErrors(context, message.cast<String>());
          }
          return _mapBadRequestError(context, message.toString());
        case 401:
          return l.unauthorizedError;
        case 404:
          return l.notFoundError;
        case 500:
          return l.internalServerError;
        default:
          return l.unknownError;
      }
    }

    return l.unknownError;
  }

  static String _handleValidationErrors(
      BuildContext context, List<String> errors) {
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

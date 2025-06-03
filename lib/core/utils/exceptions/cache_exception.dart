import 'package:flutter/material.dart';
import 'package:zoozi_wallet/l10n/app_localizations.dart';

/// Exception for handling local storage/cache errors
class CacheException implements Exception {
  final String message;
  final dynamic error;
  final String key;
  final BuildContext? context;

  CacheException({
    required this.message,
    this.error,
    required this.key,
    this.context,
  });

  factory CacheException.read(String key,
      [dynamic error, BuildContext? context]) {
    return CacheException(
      message: 'cache_read_error',
      error: error,
      key: key,
      context: context,
    );
  }

  factory CacheException.write(String key,
      [dynamic error, BuildContext? context]) {
    return CacheException(
      message: 'cache_write_error',
      error: error,
      key: key,
      context: context,
    );
  }

  factory CacheException.delete(String key,
      [dynamic error, BuildContext? context]) {
    return CacheException(
      message: 'cache_delete_error',
      error: error,
      key: key,
      context: context,
    );
  }

  String getLocalizedMessage() {
    if (context != null) {
      final l10n = AppLocalizations.of(context!);
      switch (message) {
        case 'cache_read_error':
          return l10n.cacheReadError(key);
        case 'cache_write_error':
          return l10n.cacheWriteError(key);
        case 'cache_delete_error':
          return l10n.cacheDeleteError(key);
        default:
          return l10n.unknownError;
      }
    }
    return toString();
  }

  @override
  String toString() => 'CacheException: $message (Key: $key)';
}

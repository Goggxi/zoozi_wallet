import 'package:flutter/material.dart';
import '../errors/error_mapper.dart';
import '../exceptions/api_exception.dart';

/// A record type that represents the result of an API call
/// [T] is the type of the successful response
/// [error] is the ApiException if the call failed
/// [data] is the successful response data
typedef ApiResult<T> = ({ApiException? error, T? data});

/// Extension methods for ApiResult to make it easier to work with
extension ApiResultExtension<T> on ApiResult<T> {
  /// Returns true if the result is successful (no error)
  bool get isSuccess => error == null;

  /// Returns true if the result has an error
  bool get isError => error != null;

  /// Maps the error message using the ErrorMapper if there is an error
  String getErrorMessage(BuildContext context) {
    return error != null
        ? ErrorMapper.mapErrorMessage(
            context, error!.response ?? error!.message)
        : '';
  }

  /// Executes one of the provided callbacks based on the result state
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException error) onError,
  }) {
    if (isSuccess) {
      try {
        return onSuccess(data as T);
      } catch (e) {
        // Handle void types or null data
        return onSuccess(null as T);
      }
    } else {
      return onError(error!);
    }
  }

  /// Maps the result to a new type
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return (error: null, data: mapper(data as T));
      } catch (e) {
        // Handle void types or null data
        return (error: null, data: mapper(null as T));
      }
    } else {
      return (error: error, data: null);
    }
  }
}

/// Helper function to create a successful result
ApiResult<T> Success<T>(T data) => (error: null, data: data);

/// Helper function to create an error result
ApiResult<T> Error<T>(ApiException error) => (error: error, data: null);

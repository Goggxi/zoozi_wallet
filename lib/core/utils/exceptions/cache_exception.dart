/// Exception for handling local storage/cache errors
class CacheException implements Exception {
  final String message;
  final dynamic error;

  CacheException({required this.message, this.error});

  factory CacheException.read(String key, [dynamic error]) {
    return CacheException(
      message: 'Failed to read data for key: $key',
      error: error,
    );
  }

  factory CacheException.write(String key, [dynamic error]) {
    return CacheException(
      message: 'Failed to write data for key: $key',
      error: error,
    );
  }

  factory CacheException.delete(String key, [dynamic error]) {
    return CacheException(
      message: 'Failed to delete data for key: $key',
      error: error,
    );
  }

  @override
  String toString() => 'CacheException: $message';
}

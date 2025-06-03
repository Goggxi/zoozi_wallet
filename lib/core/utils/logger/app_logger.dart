import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

abstract class IAppLogger {
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void network(String method, String url, dynamic body, dynamic response,
      int? statusCode);
}

@Singleton(as: IAppLogger)
class AppLogger implements IAppLogger {
  final Logger _logger;

  AppLogger()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
        );

  @override
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }

  @override
  void network(String method, String url, dynamic body, dynamic response,
      int? statusCode) {
    final emoji =
        statusCode != null && statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _logger.i('''
$emoji Network Request:
Method: $method
URL: $url
Body: $body
Status Code: $statusCode
Response: $response
''');
  }
}

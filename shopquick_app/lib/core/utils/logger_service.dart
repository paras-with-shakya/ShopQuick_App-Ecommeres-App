import 'package:flutter/foundation.dart';

/// Centralized logging service for the application.
/// Provides methods for logging API calls, errors, and debug information.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  /// Log verbose message
  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[V]', message, error, stackTrace);
  }

  /// Log debug message
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[D]', message, error, stackTrace);
  }

  /// Log info message
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[I]', message, error, stackTrace);
  }

  /// Log warning message
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[W]', message, error, stackTrace);
  }

  /// Log error message
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[E]', message, error, stackTrace);
  }

  /// Log fatal message
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log('[F]', message, error, stackTrace);
  }

  void _log(
    String level,
    dynamic message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer('$level $message');
    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }
    debugPrint(buffer.toString());
  }

  /// Log API request details
  void logApiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) {
    info(
      'API Request\n'
      'Method: $method\n'
      'URL: $url\n'
      'Params: $params\n'
      'Headers: $headers',
    );
  }

  /// Log API response details
  void logApiResponse({
    required String url,
    required int statusCode,
    dynamic responseBody,
  }) {
    info(
      'API Response\n'
      'URL: $url\n'
      'Status Code: $statusCode\n'
      'Response: $responseBody',
    );
  }

  /// Log API error details
  void logApiError({
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    error(
      'API Error\n'
      'URL: $url\n'
      'Error: $error',
      error,
      stackTrace,
    );
  }
}

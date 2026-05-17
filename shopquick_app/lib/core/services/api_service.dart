import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopquick_app/core/errors/index.dart';
import 'package:shopquick_app/core/constants/api_constants.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';

/// Centralized API service for all HTTP requests.
/// Handles request/response, error management, logging, and retries.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final LoggerService _logger = LoggerService();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  /// Perform a GET request
  ///
  /// [endpoint] - Full URL or relative path
  /// [headers] - Optional request headers
  /// [timeout] - Request timeout duration
  ///
  /// Throws [NetworkException] or [TimeoutException] on failure
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(
      seconds: ApiConstants.connectTimeoutDuration,
    ),
  }) async {
    try {
      _logger.logApiRequest(method: 'GET', url: endpoint, headers: headers);

      final response = await http
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(timeout);

      _logger.logApiResponse(
        url: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return _handleResponse(response);
    } on TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.logApiError(url: endpoint, error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to fetch data from $endpoint',
        originalError: e,
      );
    }
  }

  /// Perform a POST request
  ///
  /// [endpoint] - Full URL or relative path
  /// [body] - Request body data
  /// [headers] - Optional request headers
  /// [timeout] - Request timeout duration
  ///
  /// Throws [NetworkException] or [TimeoutException] on failure
  Future<dynamic> post(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration timeout = const Duration(
      seconds: ApiConstants.connectTimeoutDuration,
    ),
  }) async {
    try {
      final jsonBody = body is String ? body : jsonEncode(body);

      _logger.logApiRequest(
        method: 'POST',
        url: endpoint,
        params: body is String ? null : body,
        headers: headers,
      );

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: jsonBody,
          )
          .timeout(timeout);

      _logger.logApiResponse(
        url: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return _handleResponse(response);
    } on TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.logApiError(url: endpoint, error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to send request to $endpoint',
        originalError: e,
      );
    }
  }

  /// Perform a PUT request
  Future<dynamic> put(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration timeout = const Duration(
      seconds: ApiConstants.connectTimeoutDuration,
    ),
  }) async {
    try {
      final jsonBody = body is String ? body : jsonEncode(body);

      _logger.logApiRequest(
        method: 'PUT',
        url: endpoint,
        params: body is String ? null : body,
        headers: headers,
      );

      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: jsonBody,
          )
          .timeout(timeout);

      _logger.logApiResponse(
        url: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return _handleResponse(response);
    } on TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.logApiError(url: endpoint, error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to update resource at $endpoint',
        originalError: e,
      );
    }
  }

  /// Perform a DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(
      seconds: ApiConstants.connectTimeoutDuration,
    ),
  }) async {
    try {
      _logger.logApiRequest(method: 'DELETE', url: endpoint, headers: headers);

      final response = await http
          .delete(Uri.parse(endpoint), headers: headers)
          .timeout(timeout);

      _logger.logApiResponse(
        url: endpoint,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      return _handleResponse(response);
    } on TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.logApiError(url: endpoint, error: e, stackTrace: stackTrace);
      throw NetworkException(
        message: 'Failed to delete resource at $endpoint',
        originalError: e,
      );
    }
  }

  /// Handle HTTP response and convert errors to exceptions
  dynamic _handleResponse(http.Response response) {
    try {
      // Success responses (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return jsonDecode(response.body);
      }

      // Client errors (400-499)
      if (response.statusCode >= 400 && response.statusCode < 500) {
        if (response.statusCode == 401) {
          throw ValidationException(
            message: 'Unauthorized. Please login again.',
            code: '401',
          );
        }
        if (response.statusCode == 404) {
          throw NetworkException(message: 'Resource not found.', code: '404');
        }
        throw NetworkException(
          message: 'Invalid request: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }

      // Server errors (500-599)
      if (response.statusCode >= 500) {
        throw NetworkException(
          message: 'Server error. Please try again later.',
          code: response.statusCode.toString(),
        );
      }

      throw NetworkException(
        message: 'Unexpected error: ${response.statusCode}',
        code: response.statusCode.toString(),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to parse response',
        originalError: e,
      );
    }
  }
}

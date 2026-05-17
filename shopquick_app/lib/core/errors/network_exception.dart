import 'app_exception.dart';

/// Exception thrown when a network request fails.
/// This includes connection errors, DNS failures, and HTTP errors.
class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.originalError});
}

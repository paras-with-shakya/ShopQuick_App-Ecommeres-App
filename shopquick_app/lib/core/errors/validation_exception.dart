import 'app_exception.dart';

/// Exception thrown when validation fails.
/// Used for input validation, authentication, and data integrity checks.
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

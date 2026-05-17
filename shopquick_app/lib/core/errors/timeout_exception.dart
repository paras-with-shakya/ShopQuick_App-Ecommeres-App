import 'app_exception.dart';

/// Exception thrown when an API request times out.
class TimeoutException extends AppException {
  TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.code,
    super.originalError,
  });
}

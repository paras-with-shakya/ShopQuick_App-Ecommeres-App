import 'package:flutter/material.dart';
import 'app_exception.dart';
import 'network_exception.dart';
import 'timeout_exception.dart';
import 'validation_exception.dart';

/// Centralized error handler for the application.
/// Converts exceptions into user-friendly messages and handles error presentation.
class ErrorHandler {
  /// Get user-friendly error message from an exception.
  static String getMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    }

    if (error is NetworkException) {
      return error.message;
    }

    if (error is ValidationException) {
      return error.message;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get error code if available
  static String? getCode(dynamic error) {
    if (error is AppException) {
      return error.code;
    }
    return null;
  }

  /// Show error snackbar in the UI
  static void showErrorSnackbar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog in the UI
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String title = 'Error',
  }) async {
    final message = getMessage(error);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Log error details for debugging
  static void logError(dynamic error, {String? tag}) {
    if (error is AppException) {
      debugPrint(
        '[$tag] ${error.runtimeType}: ${error.message}\n'
        'Code: ${error.code}\n'
        'Original: ${error.originalError}',
      );
    } else {
      debugPrint('[$tag] Unexpected error: $error');
    }
  }
}

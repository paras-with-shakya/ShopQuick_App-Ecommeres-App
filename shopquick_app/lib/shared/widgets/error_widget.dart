import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';
import 'custom_button.dart';

/// Widget to display error state with message and optional retry button.
class ErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool fullScreen;
  final double iconSize;

  const ErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.fullScreen = false,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: AppColors.error),
              const SizedBox(height: 16),
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (title != null) const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                CustomButton(label: 'Retry', onPressed: onRetry, width: 120),
              ],
            ],
          ),
        ),
      ),
    );

    if (fullScreen) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), elevation: 0),
        body: widget,
      );
    }

    return widget;
  }
}

/// Custom error dialog widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        TextButton(
          onPressed: onPrimaryButtonPressed ?? () => Navigator.pop(context),
          child: Text(primaryButtonText ?? 'OK'),
        ),
      ],
    );
  }
}

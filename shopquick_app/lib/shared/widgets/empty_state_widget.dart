import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';
import 'custom_button.dart';

/// Widget to display empty state with icon, message, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool fullScreen;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
    this.fullScreen = false,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppColors.grey),
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
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 140,
              ),
            ],
          ],
        ),
      ),
    );

    if (fullScreen) {
      return Scaffold(
        appBar: AppBar(title: const Text('Empty'), elevation: 0),
        body: widget,
      );
    }

    return widget;
  }
}

/// Empty list view with shimmer loading
class EmptyListPlaceholder extends StatelessWidget {
  final int itemCount;

  const EmptyListPlaceholder({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

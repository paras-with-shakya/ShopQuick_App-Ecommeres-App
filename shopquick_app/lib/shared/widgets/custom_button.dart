import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';

/// Reusable custom button widget with loading state support.
///
/// Supports different button types: primary, secondary, outline, text
/// Can show loading indicator and disable interactions
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType buttonType;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double iconSize;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.buttonType = ButtonType.primary,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: _buildButton(context));
  }

  Widget _buildButton(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    final enabled = isEnabled && onPressed != null;

    switch (buttonType) {
      case ButtonType.primary:
        return _buildPrimaryButton(enabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(enabled);
      case ButtonType.outline:
        return _buildOutlineButton(enabled);
      case ButtonType.text:
        return _buildTextButton(enabled);
    }
  }

  Widget _buildLoadingButton() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.grey,
        disabledForegroundColor: AppColors.greyDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.accent,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.grey,
        disabledForegroundColor: AppColors.greyDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(bool enabled) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        side: BorderSide(
          color: enabled ? AppColors.primary : AppColors.borderColor,
          width: 1.5,
        ),
        disabledForegroundColor: AppColors.greyDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(bool enabled) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

enum ButtonType { primary, secondary, outline, text }

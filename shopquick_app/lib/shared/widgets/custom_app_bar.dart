import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';

/// Custom app bar widget with common configurations.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final bool showBackButton;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onLeadingPressed,
    this.showBackButton = true,
    this.backgroundColor = AppColors.primary,
    this.titleColor = AppColors.white,
    this.elevation = 0,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.bold,
    this.bottom,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: titleFontWeight,
          color: titleColor,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading:
          leading ??
          (showBackButton
              ? BackButton(
                  onPressed:
                      onLeadingPressed ?? () => Navigator.of(context).pop(),
                  color: titleColor,
                )
              : null),
      actions: actions,
      bottom: bottom,
      iconTheme: IconThemeData(color: titleColor),
    );
  }
}

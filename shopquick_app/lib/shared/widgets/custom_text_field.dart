import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';

/// Reusable custom text field widget.
///
/// Supports various features like:
/// - Custom validation
/// - Show/hide password toggle
/// - Icons (prefix, suffix)
/// - Different input types
class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final String? initialValue;
  final bool readOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.initialValue,
    this.readOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _showPassword;

  @override
  void initState() {
    super.initState();
    _showPassword = !widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: !_showPassword && widget.isPassword,
      maxLines: !_showPassword && widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary)
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() => _showPassword = !_showPassword);
                },
                child: Icon(
                  _showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.primary,
                ),
              )
            : widget.suffixIcon != null
            ? Icon(widget.suffixIcon, color: AppColors.primary)
            : null,
        counterText: '',
      ),
    );
  }
}

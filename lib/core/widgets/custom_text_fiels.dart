import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartgallery/core/utils/themes.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && !_isPasswordVisible,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: widget.enabled ? Themes.primary : Colors.grey,
        ),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: widget.enabled ? Themes.primary : Colors.grey,
                  ),
                  onPressed:
                      widget.enabled
                          ? () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          }
                          : null,
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Themes.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        labelStyle: TextStyle(
          color: widget.enabled ? Themes.primary : Colors.grey,
        ),
        filled: !widget.enabled,
        fillColor: widget.enabled ? null : Colors.grey.withOpacity(0.1),
      ),
      validator: widget.validator,
    );
  }
}

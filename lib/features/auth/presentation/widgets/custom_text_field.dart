import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        fontSize: 16,
        color: enabled ? Colors.black87 : Colors.grey[600],
        letterSpacing: obscureText ? 1.5 : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffixIcon,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF58700),
            width: 2.0,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: Colors.red,
        ),
      ),
      validator: validator,
    );
  }
}
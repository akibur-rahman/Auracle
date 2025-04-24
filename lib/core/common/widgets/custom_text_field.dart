import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(hintText: hintText, prefixIcon: prefixIcon),
    );
  }
}

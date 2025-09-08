import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleVisibility;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.black),
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: Theme.of(context).inputDecorationTheme.border,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSizes.customInputPaddingVertical,
              horizontal: AppSizes.customInputPaddingHorizontal,
            ),
          ),
        ),
        if (onToggleVisibility != null)
          IconButton(
            icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onToggleVisibility,
          ),
      ],
    );
  }
}

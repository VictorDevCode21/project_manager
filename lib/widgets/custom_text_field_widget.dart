// CustomTextField.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable text field that participates in Form validation properly.
/// It relies on TextFormField's built-in validation and error display.
class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData? iconData;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.iconData,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.enableSuggestions,
    this.autocorrect,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional label above the field (keeps layout consistent)
        Padding(padding: const EdgeInsets.only(bottom: 6)),
        TextFormField(
          // Use TextFormField so FormState can validate this field
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator, // ← let the form manage validity
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: iconData != null ? Icon(iconData) : null,
            hintText: hintText,
            counterText: '', // hide counter if using maxLength
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 164, 205, 191),
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 164, 205, 191),
                width: 1.5,
              ),
            ),
            // Proper error borders managed by the field
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Common reusable UI helper for form validation messages.
Widget errorPlaceholder(String? errorText) {
  return Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: SizedBox(
      height: 16,
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          errorText ?? '',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    ),
  );
}

// lib/widgets/app_dropdown.dart
import 'package:flutter/material.dart';

/// Reusable, form-friendly dropdown.
/// - Generic over type T
/// - You control how each item is labeled via `labelOf`
/// - Plays nicely with Form/Validator (DropdownButtonFormField)
/// - Optional "None"/placeholder state when `value` is null
class AppDropdown<T> extends StatelessWidget {
  /// Items to render as options.
  final List<T> items;

  /// Currently selected value (can be null if you want a placeholder).
  final T? value;

  /// Map an item to the visible label.
  final String Function(T) labelOf;

  /// Callback when selection changes.
  final void Function(T?)? onChanged;

  /// Optional validator integrated with Form.
  final String? Function(T?)? validator;

  /// Optional label shown inside the input decoration.
  final String? labelText;

  /// Optional hint text shown when no value is selected.
  final String? hintText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Optional flag to expand the dropdown to fill available width.
  final bool isExpanded;

  /// Optional icon override.
  final Widget? icon;

  /// Optional helper/error text below the field.
  final String? helperText;

  /// Optional item builder hook if you need custom row widgets per item.
  final Widget Function(BuildContext, T)? itemBuilder;

  const AppDropdown({
    super.key,
    required this.items,
    required this.labelOf,
    this.value,
    this.onChanged,
    this.validator,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.isExpanded = true,
    this.icon,
    this.helperText,
    this.itemBuilder,
  });

  InputDecoration _decoration(BuildContext context) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    filled: true,
    fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: itemBuilder != null
                  ? itemBuilder!(context, e)
                  : Text(labelOf(e)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      icon: icon,
      decoration: _decoration(context),
    );
  }
}

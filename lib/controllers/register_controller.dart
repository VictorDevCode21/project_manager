// register_controller.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Manages user registration logic and form validation.
/// Note: This controller is SILENT on client-side invalid form.
/// It returns false without showing SnackBars when the form is invalid,
/// so the View can keep the user on the screen and show red errors only.
class RegisterController {
  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final personIdController = TextEditingController();

  // Extra state
  String? selectedRole;
  DateTime? selectedDate;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Services
  final AuthService _authService = AuthService();

  // ===== Validations =====
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras y espacios';
    }
    return null;
  }

  String? validatePersonId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Por favor, ingresa tu cédula";
    }
    if (!RegExp(r'^\d{6,10}$').hasMatch(value)) {
      return "Cédula inválida (solo números, entre 6 y 10 dígitos)";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }
    return null;
  }

  // Strict: requires exactly 11 digits starting with 0 and a valid carrier prefix.
  String? validatePhone(String? value) {
    // Basic presence check
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de teléfono';
    }

    // Match Venezuelan mobile format: 0 + (424|412|414|416|422) + 7 digits
    final regex = RegExp(r'^0(424|412|414|416|422)\d{7}$');

    if (!regex.hasMatch(value.trim())) {
      return 'Número inválido. Formato: 0(414|424|412|422|416 ) + 7 dígitos';
    }

    return null; // valid
  }

  // Strong password validator:
  // - At least 10 chars
  // - At least 1 uppercase, 1 lowercase, 1 digit, 1 symbol
  // - No whitespace
  // - Not equal to personal fields (email, name, id) when provided
  // - No obvious repeated same char (e.g., "aaaaaaaaaa")
  String? strongPasswordValidator(
    String? value, {
    String? email,
    String? name,
    String? personId,
  }) {
    // Presence
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }

    final pwd = value;

    // No whitespace allowed
    if (RegExp(r'\s').hasMatch(pwd)) {
      return 'La contraseña no debe contener espacios';
    }

    // Length
    if (pwd.length < 10) {
      return 'Debe tener al menos 10 caracteres';
    }

    // Character classes
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasLower = RegExp(r'[a-z]').hasMatch(pwd);
    final hasDigit = RegExp(r'\d').hasMatch(pwd);
    final hasSymbol = RegExp(
      r'[^\w]',
    ).hasMatch(pwd); // anything not letter/digit/_

    if (!(hasUpper && hasLower && hasDigit && hasSymbol)) {
      return 'Debe incluir mayúsculas, minúsculas, números y símbolos';
    }

    // Avoid trivial repeated single-char like "!!!!!!!!!!" or "aaaaaaaaaa"
    if (RegExp(r'^(.)\1{5,}$').hasMatch(pwd)) {
      return 'Demasiado simple: caracteres repetidos';
    }

    // Avoid matching personal data (basic)
    String normalize(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    final pwdNorm = normalize(pwd);
    if (email != null && email.isNotEmpty) {
      final emailUser = normalize(email.split('@').first);
      if (emailUser.isNotEmpty && pwdNorm.contains(emailUser)) {
        return 'No uses datos personales en la contraseña';
      }
    }
    if (name != null && name.isNotEmpty && pwdNorm.contains(normalize(name))) {
      return 'No uses tu nombre en la contraseña';
    }
    if (personId != null &&
        personId.isNotEmpty &&
        pwdNorm.contains(normalize(personId))) {
      return 'No uses tu cédula en la contraseña';
    }

    // Looks good
    return null;
  }

  String? validatePassword(String? value) {
    // Read other fields from internal controllers so you don't need params in the widget
    return strongPasswordValidator(
      value,
      email: emailController.text,
      name: nameController.text,
      personId: personIdController.text,
    );
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Repite la contraseña';
    if (value != passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateRole() =>
      selectedRole == null ? 'Selecciona un tipo de usuario' : null;

  String? validateDate() {
    if (selectedDate == null) return 'Selecciona una fecha';
    if (selectedDate!.isAfter(DateTime.now())) {
      return 'Selecciona una fecha válida ';
    }
    return null;
  }

  /// Returns true if the full form is valid including role and date.
  bool get isFormCompletelyValid {
    final fieldsValid = formKey.currentState?.validate() ?? false;
    return fieldsValid && validateRole() == null && validateDate() == null;
  }

  /// Normalizes inputs AFTER validation passed.
  void _normalizeInputs() {
    emailController.text = emailController.text.trim().toLowerCase();
    phoneController.text = phoneController.text.trim();
    passwordController.text = passwordController.text.trim();
    confirmPasswordController.text = confirmPasswordController.text.trim();
  }

  /// Registers the user. Returns true on success, false otherwise.
  /// - If the form is invalid (client-side), returns false WITHOUT SnackBars.
  /// - On success, shows a success SnackBar.
  /// - On backend error, shows the error SnackBar and returns false.
  Future<bool> registerUser(BuildContext context) async {
    // Trigger validators on all fields in the Form
    final fieldsValid = formKey.currentState?.validate() ?? false;

    // If any client-side invalid, stay silent and let red errors be shown by the fields
    if (!fieldsValid || validateRole() != null || validateDate() != null) {
      return false;
    }

    // Optionally save state
    formKey.currentState?.save();

    // Normalize inputs before hitting the network
    _normalizeInputs();

    try {
      final user = await _authService.registerUser(
        name: nameController.text.trim(),
        email: emailController.text,
        password: passwordController.text,
        phoneNumber: phoneController.text,
        role: selectedRole ?? 'USER',
        birthDate: selectedDate!,
        personId: personIdController.text.trim(),
      );

      if (user != null) {
        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );
        return true;
      }

      // Unexpected null user: treat as failure without extra noise
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    personIdController.dispose();
  }
}

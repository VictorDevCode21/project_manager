import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Manages user registration logic and form validation.
class RegisterController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedRole;
  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // ===== FIELD VALIDATORS =====
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Por favor, ingresa tu nombre';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu correo electrónico';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu número de teléfono';
    if (!RegExp(r'^\d{7,11}$').hasMatch(value)) return 'Número inválido';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Repite la contraseña';
    if (value != passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateRole() =>
      selectedRole == null ? 'Selecciona un tipo de usuario' : null;
  String? validateDate() =>
      selectedDate == null ? 'Selecciona una fecha' : null;

  bool validateForm() {
    final valid = formKey.currentState?.validate() ?? false;
    return valid && selectedRole != null && selectedDate != null;
  }

  /// Handles the registration process with Firebase Auth and Firestore.
  Future<void> registerUser(BuildContext context) async {
    if (!validateForm()) return;

    // Avoid calling setState or using context if the widget was disposed
    if (!context.mounted) return;

    try {
      final user = await _authService.registerUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phoneNumber: phoneController.text,
        role: selectedRole ?? 'USER',
        birthDate: selectedDate!,
      );

      if (user != null) {
        final token = await _authService.getToken();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );

        // Optionally navigate or store token securely here
        debugPrint(
          'User registered successfully. Token length: ${token?.length}',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

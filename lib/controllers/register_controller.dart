import 'package:flutter/material.dart';

class RegisterController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedRole;
  DateTime? selectedDate;

  final formKey = GlobalKey<FormState>();

  // ===== VALIDATORS =====
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu número de teléfono';
    } else if (!RegExp(r'^\d{7,11}$').hasMatch(value)) {
      return 'Número inválido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    } else if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repite la contraseña';
    } else if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? validateRole() {
    if (selectedRole == null) {
      return 'Selecciona un tipo de usuario';
    }
    return null;
  }

  String? validateDate() {
    if (selectedDate == null) {
      return 'Selecciona una fecha';
    }
    return null;
  }

  // ===== GENERAL VALIDATION =====
  bool validateForm() {
    final valid = formKey.currentState?.validate() ?? false;
    return valid && selectedRole != null && selectedDate != null;
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

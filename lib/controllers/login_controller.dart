// lib/controllers/login_controller.dart
import 'package:flutter/material.dart'; // Corregido: 'package:' en lugar de 'package.'
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Handles user login logic, form validation and session management.
class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Validates institutional UNIMET email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es obligatorio';

    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales UNIMET';
    }

    return null;
  }

  /// Validates password field
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    return null;
  }

  /// Performs login through AuthProvider and redirects by role
  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    // Aquí el error de _formKey no aparece porque la variable existe.
    if (!formKey.currentState!.validate()) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Access AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 2️⃣ Execute login
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 3️⃣ Get user info from provider
      final role = authProvider.role;

      // 4️⃣ Show welcome message and navigate based on role
      if (context.mounted) {

        // (El SnackBar de "Bienvenido" se maneja en AdminLayout)

        if (role == 'ADMIN' || role == 'COORDINATOR' || role == 'USER') {
          context.go('/admin-dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      // Handle login error gracefully
      _errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
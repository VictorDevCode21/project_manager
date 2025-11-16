// lib/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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

  /// Toggles password visibility on the login form.
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Validates institutional UNIMET email format.
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }

    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales UNIMET';
    }

    return null;
  }

  /// Validates password field.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    return null;
  }

  /// Performs login through AuthProvider and redirects based on role.
  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1) Access AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 2) Execute login via AuthProvider
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 3) Read role from AuthProvider
      final role = authProvider.role;

      // 4) Navigate based on role
      if (context.mounted) {
        if (role == 'ADMIN' || role == 'COORDINATOR' || role == 'USER') {
          context.go('/admin-homepage');
        } else {
          context.go('/');
        }
      }
    } catch (error) {
      debugPrint('[LoginController] error type: ${error.runtimeType}');
      debugPrint('[LoginController] error: $error');

      final String message = _mapLoginErrorToMessage(error);
      _errorMessage = message;

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maps any login error (FirebaseAuth or wrapped) to a friendly Spanish message.
  String _mapLoginErrorToMessage(Object error) {
    // Case 1: We received a raw FirebaseAuthException.
    if (error is fb_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña inválidos. Verifique sus datos.';
        case 'user-disabled':
          return 'Tu cuenta ha sido deshabilitada. Por favor, contacta al administrador.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Inténtalo de nuevo en unos minutos.';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
        default:
          return 'No se pudo iniciar sesión en este momento. Inténtalo de nuevo.';
      }
    }

    // Case 2: Error wrapped by AuthService/AuthProvider or as a generic Exception.
    final raw = error.toString();

    // Try to detect Firebase-style codes inside the message string.
    if (raw.contains('wrong-password') ||
        raw.contains('user-not-found') ||
        raw.contains('invalid-credential') ||
        raw.contains('invalid-email')) {
      return 'Correo o contraseña inválidos. Verifica tus datos.';
    }

    if (raw.contains('user-disabled')) {
      return 'Tu cuenta ha sido deshabilitada. Por favor, contacta al administrador.';
    }

    if (raw.contains('too-many-requests')) {
      return 'Demasiados intentos fallidos. Inténtalo de nuevo en unos minutos.';
    }

    if (raw.contains('network-request-failed')) {
      return 'Error de conexión. Verifica tu conexión a internet e inténtalo de nuevo.';
    }

    // Fallback for any other unknown / server-side error.
    return 'Ocurrió un error inesperado al iniciar sesión. Inténtalo de nuevo.';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';

/// Handles user login logic, form validation and Firebase authentication.
class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
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

  /// Validates that the email is a valid UNIMET institutional address.
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }

    // Allow both institutional domains
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

  /// Handles the full Firebase login process.
  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Authenticate user using AuthService
      final result = await _authService.loginUser(
        email: emailController.text,
        password: passwordController.text,
      );

      // 2️⃣ Extract useful user info
      final String name = result['name'];
      final String role = result['role'];
      final String token = result['token'];

      // 3️⃣ (Optional) Save session locally or log it
      debugPrint('✅ Usuario autenticado: $name');
      debugPrint('Rol: $role');
      debugPrint('Token length: ${token.length}');

      // 4️⃣ Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bienvenido $name')));

        // 5️⃣ Navigate based on role (customize this later)
        if (role == 'COORDINATOR' || role == "USER" || role == "ADMIN") {
          context.go('/admin-dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      // Handle errors gracefully
      _errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
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

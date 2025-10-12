import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  final String requiredDomain = '@correo.unimet.edu.ve';
  bool _isPasswordVisible = false; // Estado de visibilidad

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!value.endsWith(requiredDomain)) {
      return 'Solo se permiten correos del dominio $requiredDomain';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Formato de correo inválido';
    }
    return null;
  }

  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulación de Carga
    await Future.delayed(const Duration(seconds: 1));

    // Constantes de "autenticación" local para la simulación
    const String VALID_EMAIL = 'admin@correo.unimet.edu.ve';
    const String VALID_PASSWORD = 'password123';

    // Lógica de "Inicio de Sesión" LOCAL
    if (emailController.text.trim() == VALID_EMAIL &&
        passwordController.text == VALID_PASSWORD) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _errorMessage =
          'Credenciales incorrectas. Usa admin@correo.unimet.edu.ve / password123';
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

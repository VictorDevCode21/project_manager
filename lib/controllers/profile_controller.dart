/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prolab_unimet/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

//mañana

class ProfileController {
  final newnameController = TextEditingController();
  final newemailController = TextEditingController();
  final newphoneController = TextEditingController();
  final newpasswordController = TextEditingController();
  final newpersonIdController = TextEditingController();
  final descController = TextEditingController();

  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    return null;
  }

  String? validatePersonId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Por favor, ingresa tu cédula";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    // Allow only UNIMET institutional emails
    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }

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

  String? validateDate() =>
      selectedDate == null ? 'Selecciona una fecha' : null;

  bool validateForm() {
    final valid = formKey.currentState?.validate() ?? false;
    return valid != null && selectedDate != null;
  }

  Future<User> modifyUser({
     String? name,
     String? email,
     String? password,
     String? phoneNumber,
     DateTime? birthDate,
     String? personId,
  }) async {
    User? user = await ;
    user.email = 
    
    
  }
}*/

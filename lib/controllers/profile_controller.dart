import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/register_controller.dart';

class ProfileController {
  // Text controllers should be final for better immutability.
  final TextEditingController newnameController = TextEditingController();
  final TextEditingController oldemailController = TextEditingController();
  final TextEditingController newemailController = TextEditingController();
  final TextEditingController newphoneController = TextEditingController();
  final TextEditingController oldpasswordController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController newpersonIdController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  DateTime? selectedDate;

  Future<String> getName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final String uid = user.uid;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final Map<String, dynamic>? userData = snapshot.data();
    if (userData == null || !snapshot.exists) {
      throw Exception('No se encontró información del usuario.');
    }

    return userData['name'] as String? ?? 'Sin nombre';
  }

  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre completo';
    }

    final String trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    // Optional: restrict to letters and spaces
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(trimmed)) {
      return 'El nombre solo puede contener letras y espacios';
    }

    return null;
  }

  String? validarCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu cédula';
    }

    final String trimmed = value.trim();

    // Only digits
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'La cédula solo puede contener números';
    }

    // Length between 6 and 8 digits (typical VE IDs)
    if (trimmed.length < 4 || trimmed.length > 8) {
      return 'La cédula debe tener entre 4 y 8 dígitos';
    }

    final int? numericValue = int.tryParse(trimmed);
    if (numericValue == null) {
      return 'La cédula no es válida';
    }

    // Must be < 100.000.000
    if (numericValue <= 0 || numericValue >= 100000000) {
      return 'La cédula debe ser un número menor a 100.000.000';
    }

    return null;
  }

  String? validarCorreo(String? value) {
    final RegExp regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );

    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final String trimmed = value.trim();

    if (!regex.hasMatch(trimmed)) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }

    return null;
  }

  String? validarPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de teléfono';
    }

    final String trimmed = value.trim();
    // This regex already ensures that it is numeric and has the correct prefix
    final RegExp regex = RegExp(r'^0(424|412|414|416|422)\d{7}$');

    if (!regex.hasMatch(trimmed)) {
      return 'Número inválido. Usa el formato 04xx + 7 dígitos (ej: 04141234567)';
    }

    return null;
  }

  String? validarPassword(String? value) {
    final RegisterController regcon = RegisterController();
    return regcon.validatePassword(value);
  }

  String? validarDate() {
    if (selectedDate == null) {
      return 'Selecciona tu fecha de nacimiento';
    }

    final DateTime today = DateTime.now();
    final DateTime birthDate = selectedDate!;

    if (birthDate.isAfter(today)) {
      return 'La fecha de nacimiento no puede ser en el futuro';
    }

    // Calculate exact age in years
    int age = today.year - birthDate.year;
    final DateTime birthdayThisYear = DateTime(
      today.year,
      birthDate.month,
      birthDate.day,
    );
    if (birthdayThisYear.isAfter(today)) {
      age -= 1;
    }

    if (age > 120) {
      return 'La edad no puede ser mayor a 120 años';
    }

    return null;
  }

  Future<void> cancelarAccion(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final String uid = user.uid;
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final Map<String, dynamic>? userData = snapshot.data();
      if (userData == null) return;

      newnameController.text = userData['name'] as String? ?? '';
      newemailController.text = userData['email'] as String? ?? '';
      newphoneController.text = userData['phone_number'] as String? ?? '';
      newpersonIdController.text = userData['personId'] as String? ?? '';
      descController.text = userData['description'] as String? ?? '';

      final String? birthDateStr = userData['birth_date'] as String?;
      if (birthDateStr != null && birthDateStr.isNotEmpty) {
        selectedDate = DateTime.tryParse(birthDateStr);
      }
    } catch (e) {
      debugPrint('[ProfileController] cancelarAccion error: $e');
    }
  }

  /// Updates profile after validating the given [formKey].
  /// Updates profile data in Firestore. Assumes the form was already validated.
  Future<void> modificarPerfil(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado.');
      }

      final String uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': newnameController.text.trim(),
        'phone_number': newphoneController.text.trim(),
        'description': descController.text.trim(),
        'personId': newpersonIdController.text.trim(),
        'birth_date': selectedDate?.toIso8601String(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Perfil modificado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      await cancelarAccion(context);
    } catch (e) {
      debugPrint('[ProfileController] modificarPerfil error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Ocurrió un error al modificar el perfil.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> modificarLogin(BuildContext context) async {
    try {
      final String? oldEmailError = validarCorreo(oldemailController.text);
      final String? newEmailError = validarCorreo(newemailController.text);
      final String? oldPassError = validarPassword(oldpasswordController.text);
      final String? newPassError = validarPassword(newpasswordController.text);

      if (oldEmailError != null ||
          newEmailError != null ||
          oldPassError != null ||
          newPassError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Revisa los datos de correo y contraseña. Algunos campos son inválidos.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado.');
      }

      if (user.email != oldemailController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El correo actual no coincide con el registrado en la cuenta.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: oldemailController.text.trim(),
        password: oldpasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      if (user.email != newemailController.text.trim()) {
        await user.verifyBeforeUpdateEmail(newemailController.text.trim());
      }

      if (oldpasswordController.text != newpasswordController.text) {
        await user.updatePassword(newpasswordController.text);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        <String, dynamic>{'email': newemailController.text.trim()},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Datos de inicio de sesión modificados correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('[ProfileController] modificarLogin error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ No se pudieron modificar los datos de inicio de sesión.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Dispose controllers to avoid memory leaks.
  void dispose() {
    newnameController.dispose();
    oldemailController.dispose();
    newemailController.dispose();
    newphoneController.dispose();
    oldpasswordController.dispose();
    newpasswordController.dispose();
    newpersonIdController.dispose();
    descController.dispose();
  }
}

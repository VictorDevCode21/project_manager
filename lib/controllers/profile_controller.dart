import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prolab_unimet/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfileController {
  TextEditingController newnameController = TextEditingController();
  TextEditingController newemailController = TextEditingController();
  TextEditingController newphoneController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController newpersonIdController = TextEditingController();
  TextEditingController descController = TextEditingController();

  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    return null;
  }

  String? validarCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Por favor, ingresa tu cédula";
    }
    return null;
  }

  String? validarCorreo(String? value) {
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

  String? validarPhone(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu número de teléfono';
    if (!RegExp(r'^\d{7,11}$').hasMatch(value)) return 'Número inválido';
    return null;
  }

  String? validarPassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  String? validarDate() => selectedDate == null ? 'Selecciona una fecha' : null;

  Future<void> cancelarAccion(BuildContext context) async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      String uid = user!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      var usermod = snapshot.data();
      newnameController.text = usermod!['name'];
      newemailController.text = usermod['email'];
      newphoneController.text = usermod['phone_number'];
      newpersonIdController.text = usermod['personId'];
      selectedDate = DateTime.parse(usermod['birth_date']);
      descController.text = usermod['description'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> modificarPerfil(BuildContext context) async {
    if (validarCedula(newpersonIdController.text) == null &&
        validarCorreo(newemailController.text) == null &&
        validarPassword(newpasswordController.text) == null &&
        validarNombre(newnameController.text) == null &&
        validarPhone(newphoneController.text) == null) {
      try {
        var user = FirebaseAuth.instance.currentUser;
        String uid = user!.uid;
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        var usermod = snapshot.data();
        newnameController.text = usermod!['name'];

        var rol = usermod['role'];
        var creadoen = usermod['created-at'];
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': newnameController.text,
          'email': newemailController.text.trim(),
          'phone_number': newphoneController.text,
          'role': rol,
          'description': descController.text,
          'personId': newpersonIdController.text,
          'birth_date': selectedDate?.toIso8601String(),
          'created_at': FieldValue.serverTimestamp(), //Cambiar luego
          'updated_at': FieldValue.serverTimestamp(),
        });
        if (newpasswordController.text != '') {
          user.updatePassword(newpasswordController.text);
        }
        debugPrint('Accion exitosa');
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      cancelarAccion(context);
    }
  }
}


/* 

birth_date
"2005-01-01T00:00:00.000"
(cadena)


created_at
24 de octubre de 2025, 8:15:52 p.m. UTC-4
(marca de tiempo)


description
""
(cadena)


email
"r.fernandez@correo.unimet.edu.ve"
(cadena)


id
"TKLO5f6e92Qph5vSkl7MMeRrIlL2"
(cadena)


name
"r"
(cadena)


personId
"30715177"
(cadena)


phone_number
"04241832750"
(cadena)


role
"COORDINATOR"
(cadena)


updated_at
24 de octubre de 2025, 8:15:52 p.m. UTC-4
 */
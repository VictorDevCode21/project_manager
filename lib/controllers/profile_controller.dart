import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileController {
  TextEditingController newnameController = TextEditingController();
  TextEditingController newemailController = TextEditingController();
  TextEditingController newphoneController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController newpersonIdController = TextEditingController();
  TextEditingController descController = TextEditingController();

  DateTime? selectedDate;

  Future<String> getName() async {
    var user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    var usermod = snapshot.data();
    String newname = usermod!['name'];
    return newname;
  }

  String? validarNombre(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    return null;
  }

  String? validarCedula(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Ingresa tu cédula';
    }
    if (v.length > 8 || v.length < 6) {
      return 'Cedula invalida';
    }
    return null;
  }

  String? validarCorreo(String? v) {
    var regex1 = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );
    if (v == null || v.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    if (!regex1.hasMatch(v.trim())) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }
    return null;
  }

  String? validarPhone(String? v) {
    var regex2 = RegExp(r'^\d{7,11}$');
    if (v == null || v.isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    if (regex2.hasMatch(v)) {
      return 'Número inválido';
    }
    return null;
  }

  String? validarPassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (v.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    if (v.length > 30) {
      return 'Debe tener a lo sumo 30 caracteres';
    }
    if (v == '123456') {
      return 'Contraseña muy debil';
    }
    if (v == 'password') {
      return 'Contraseña muy debil';
    }
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
        var rol = usermod!['role'];
        final creadoen = usermod['created-at'];
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': newnameController.text,
          'email': newemailController.text.trim(),
          'phone_number': newphoneController.text,
          'role': rol,
          'description': descController.text,
          'personId': newpersonIdController.text,
          'birth_date': selectedDate?.toIso8601String(),
          'created_at': creadoen,
          'updated_at': FieldValue.serverTimestamp(),
        });
        user.verifyBeforeUpdateEmail(newemailController.text.trim());
        if (newpasswordController.text != '') {
          if (validarCedula(newpasswordController.text) == null) {
            user.updatePassword(newpasswordController.text);
          } else {
            cancelarAccion(context);
          }
        } else {
          debugPrint('Guardado sin contraseña');
        }
        debugPrint('Accion exitosa');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se han realizado los cambios correctamente'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Debe loguearse de nuevo para proceder con la accion',
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Este correo ya existe')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error en la modificacion de perfil')),
          );
        }
      }
    } else {
      cancelarAccion(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: algun campo no esta bien puesto')),
      );
    }
  }
}

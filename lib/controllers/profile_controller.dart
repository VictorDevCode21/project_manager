import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/register_controller.dart';

class ProfileController {
  TextEditingController newnameController = TextEditingController();
  TextEditingController oldemailController = TextEditingController();
  TextEditingController newemailController = TextEditingController();
  TextEditingController newphoneController = TextEditingController();
  TextEditingController oldpasswordController = TextEditingController();
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

  String? validarPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    final regex = RegExp(r'^0(424|412|414|416|422)\d{7}$');

    if (!regex.hasMatch(value.trim())) {
      return 'Número inválido. Formato: 0(414|424|412|422|416 ) + 7 dígitos';
    }

    return null;
  }

  String? validarPassword(String? v) {
    RegisterController regcon = RegisterController();
    return regcon.validatePassword(v);
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
        validarNombre(newnameController.text) == null &&
        validarPhone(newphoneController.text) == null) {
      try {
        var user = FirebaseAuth.instance.currentUser;
        String uid = user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': newnameController.text,
          'phone_number': newphoneController.text,
          'description': descController.text,
          'personId': newpersonIdController.text,
          'birth_date': selectedDate?.toIso8601String(), //Cambiar luego
          'updated_at': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil modificado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        cancelarAccion(context);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al modificar los datos '),
          backgroundColor: Colors.red,
        ),
      );
      cancelarAccion(context);
    }
  }

  Future<void> modificarLogin(BuildContext context) async {
    if (validarPassword(oldpasswordController.text) == null &&
        validarPassword(newpasswordController.text) == null &&
        validarCorreo(oldemailController.text) == null &&
        validarCorreo(newemailController.text) == null &&
        FirebaseAuth.instance.currentUser!.email ==
            oldemailController.text.trim()) {
      try {
        var user = FirebaseAuth.instance.currentUser;
        String uid = user!.uid;
        AuthCredential credential = EmailAuthProvider.credential(
          email: oldemailController.text.trim(),
          password: oldpasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        if (user.email != newemailController.text.trim()) {
          user.verifyBeforeUpdateEmail(newemailController.text.trim());
        }
        if (oldpasswordController.text != newpasswordController.text) {
          user.updatePassword(newpasswordController.text);
        }
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'email': newemailController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos modificados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al modificar los datos '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

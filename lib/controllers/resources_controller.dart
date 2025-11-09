import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class ResourcesController {
  final nameController = TextEditingController();
  final kindController = TextEditingController();
  final tarifController = TextEditingController();
  final specs = TextEditingController();
  final review = TextEditingController();
  final usage = TextEditingController();
  final totalUsage = TextEditingController();
  final email = TextEditingController();
  final habilities = TextEditingController();
  final searchC = TextEditingController();

  String? labC;
  String? stateC;
  String? departmentC;
  String? conditionC;
  DateTime? lastDate;
  DateTime? nextDate;
  String? filter;

  String? validateName(String? value) {
    if (value!.trim().isEmpty || value == null) {
      return 'El campo Nombre esta vacio';
    }
    return null;
  }

  String? validateFilter() =>
      filter == null ? 'Selecciona el filtro de busqueda' : null;

  String? validateLab() =>
      labC == null ? 'Selecciona un tipo de usuario' : null;

  String? validateCondition() =>
      conditionC == null ? 'Selecciona un tipo de usuario' : null;

  String? validateState() =>
      stateC == null ? 'Selecciona un tipo de usuario' : null;

  String? validateDepartment() =>
      departmentC == null ? 'Selecciona un tipo de usuario' : null;

  String? validateTarif(String? value) {
    debugPrint(value);
    try {
      if (value!.isNotEmpty || value == null) {
        int tarifa = int.parse(value);
        if (tarifa < 0) {
          return 'Numero negativo';
        } else {
          debugPrint(value);
          return null;
        }
      }
    } catch (e) {
      debugPrint('no hay un numero error');
      return 'No has puesto un numero';
    }
    return null;
  }

  String? validateHabilities(String? value) {
    if (value!.trim().isEmpty || value == null) {
      return 'El campo Habilidades esta vacio';
    }
    return null;
  }

  String? validateSpecs(String? value) {
    if (value!.trim().isEmpty || value == null) {
      return 'El campo Specs esta vacio';
    }
    return null;
  }

  String? validateLastDate() {
    if (lastDate == null) return 'Selecciona una fecha';
    if (lastDate!.isAfter(DateTime.now())) {
      return 'Selecciona una fecha válida ';
    }
    return null;
  }

  String? validateNextDate() {
    if (nextDate == null) return 'Selecciona una fecha';
    if (nextDate!.isBefore(DateTime.now())) {
      return 'Selecciona una fecha válida ';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }
    return null;
  }

  bool validateHRFields() {
    if (validateDepartment() != null &&
        validateHabilities(habilities.text) == null &&
        validateEmail(email.text) == null &&
        validateState() != null &&
        validateTarif(tarifController.text) == null &&
        validateTarif(usage.text) == null &&
        validateLab() != null &&
        validateName(nameController.text) == null) {
      return true;
    } else {
      return false;
    }
  }

  bool validateMRFields() {
    if (validateLastDate() != null &&
        validateNextDate() == null &&
        validateState() != null &&
        validateSpecs(specs.text) == null &&
        validateLab() != null &&
        validateName(nameController.text) == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> createHResource(BuildContext context) async {
    if (validateHRFields() == true) {
      try {
        await FirebaseFirestore.instance
            .collection("human-resources")
            .doc()
            .set({
              'name': nameController.text,
              'state': stateC,
              'lab': labC,
              'projects': null,
              'mail': email.text.trim(),
              'tarif': int.parse(tarifController.text),
              'use': int.parse(usage.text),
              'habilities': habilities.text,
              'department': departmentC,
            });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recurso humano creado correctamente')),
        );
      } catch (e) {}
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Epale te falta algo')));
    }
  }

  Future<void> createMResource(BuildContext context) async {
    if (validateHRFields() == true) {
      try {
        await FirebaseFirestore.instance
            .collection("material_resource")
            .doc()
            .set({
              'name': nameController.text,
              'state': stateC,
              'projects': null,
              'lab': labC,
              'lastDate': lastDate!.toIso8601String(),
              'habilities': nextDate!.toIso8601String(),
              'specs': specs.text,
            });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recurso humano creado correctamente')),
        );
      } catch (e) {}
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Epale te falta algo')));
    }
  }

  Future<List> getHResources() async {
    List<Map> lista = List.empty();
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('human-resources')
          .get();
      for (var i in snap.docs) {
        Map<String, dynamic> data = i.data() as Map<String, dynamic>;
        lista.add(data);
      }
      return lista;
    } catch (e) {
      return lista;
    }
  }
}

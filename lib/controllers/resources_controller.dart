// resources_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/resources_model.dart';
import '../services/auth_service.dart';

class ResourcesController {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final kindController = TextEditingController();
  final tarifController = TextEditingController();
  final specs = TextEditingController();
  final review = TextEditingController();
  final usage = TextEditingController();
  final totalUsage = TextEditingController();
  final email = TextEditingController();
  final habilities = TextEditingController();

  // ValueNotifiers for filtering status and resource type
  final ValueNotifier<String> resourceType = ValueNotifier<String>('Humanos');
  final ValueNotifier<String> selectedStateFilter = ValueNotifier<String>(
    'Todos los estados',
  );
  final searchC = TextEditingController();

  // ValueNotifier that will contain the Stream of filtered resources (for the UI)
  late final ValueNotifier<Stream<List<ResourcesModel>>>
  filteredResourcesStream;

  String? labC;
  String? stateC;
  String? departmentC;
  String? conditionC;
  DateTime? lastDate;
  DateTime? nextDate;
  String? filter;

  // Constructor: Initializes the stream and adds listeners for searching and filtering
  ResourcesController() {
    filteredResourcesStream = ValueNotifier(_buildResourceStream());

    searchC.addListener(_updateStream);
    selectedStateFilter.addListener(_updateStream);
    resourceType.addListener(_updateStream);
  }

  // Method to delete a resource by its ID
  Future<void> deleteResource(String resourceId) async {
    // AÑADIDO: Creamos una variable local para la colección.
    String collection = resourceType.value == 'Humanos'
        ? 'human-resources'
        : 'material-resources';

    try {
      // AÑADIDO: Verificación de rol antes de la operación de Firestore
      final role = await getCurrentUserRole();
      if (role != 'ADMIN' && role != 'COORDINATOR') {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message:
              'No tienes permisos suficientes (rol: $role) para eliminar este recurso.',
        );
      }
      // FIN AÑADIDO

      await _firestore.collection(collection).doc(resourceId).delete();

      print('Recurso $resourceId eliminado con éxito.');

      await fetchAndCalculateStats();
    } catch (e) {
      print('Error al eliminar el recurso: $e');
      rethrow;
    }
  }

  Stream<List<ResourcesModel>> _buildResourceStream() {
    String collection = resourceType.value == 'Humanos'
        ? 'human-resources'
        : 'material-resources';

    Query collectionRef = FirebaseFirestore.instance.collection(collection);

    return collectionRef.snapshots().map((snapshot) {
      String searchText = searchC.text.toLowerCase().trim();
      String currentFilter = selectedStateFilter.value;

      return snapshot.docs
          .map((doc) {
            // 1. CREAMOS UN OBJETO TEMPORAL QUE CONTIENE EL ID Y LOS DATOS.
            // Esto evita perder el ID al extraer solo doc.data().
            return {'id': doc.id, 'data': doc.data() as Map<String, dynamic>};
          })
          .where((item) {
            final data =
                item['data']
                    as Map<String, dynamic>; // Extraemos los datos para filtrar

            bool matchesState =
                currentFilter == 'Todos los estados' ||
                (data['state'] as String? ?? 'N/A') == currentFilter;

            bool matchesSearch =
                searchText.isEmpty ||
                (data['name'] as String? ?? '').toLowerCase().contains(
                  searchText,
                ) ||
                (data['lab'] as String? ?? '').toLowerCase().contains(
                  searchText,
                );

            return matchesState && matchesSearch;
          })
          .map((item) {
            final data = item['data'] as Map<String, dynamic>;
            final id =
                item['id'] as String; // 2. RECUPERAMOS EL ID DEL MAPA TEMPORAL

            if (resourceType.value == 'Humanos') {
              return HumanResources(
                id: id, // <--- ¡AÑADIDO!
                review: data['review'] ?? '',
                usage: data['use'] ?? 0,
                totalUsage: data['totalUsage'] ?? 0,
                email: data['mail'] ?? '',
                habilities: data['habilities'] ?? '',
                department: data['department'] ?? '',
                name: data['name'] ?? 'N/A',
                state: data['state'] ?? 'N/A',
                lab: data['lab'] ?? 'N/A',
                kind: 'Humano',
                hourlyTarif: (data['tarif'] as num? ?? 0).toDouble(),
              );
            } else {
              return MaterialResource(
                id: id, // <--- ¡AÑADIDO!
                lastMaintenance: data['lastDate'] != null
                    ? DateTime.tryParse(data['lastDate']) ?? DateTime(2000)
                    : DateTime(2000),
                nextMaintenance: data['nextDate'] != null
                    ? DateTime.tryParse(data['nextDate']) ?? DateTime(2000)
                    : DateTime(2000),
                specs: data['specs'] ?? '',
                condition: data['condition'] ?? 'N/A',
                name: data['name'] ?? 'N/A',
                state: data['state'] ?? 'N/A',
                lab: data['lab'] ?? 'N/A',
                kind: 'Material',
                hourlyTarif: (data['tarif'] as num? ?? 0).toDouble(),
              );
            }
          })
          .toList();
    });
  }

  // Function that is called when the search or filter changes, forcing the reconstruction of the Stream
  void _updateStream() {
    filteredResourcesStream.value = _buildResourceStream();
  }

  // It updates to modify the ValueNotifier (the listener does the rest)
  void changeResourceType(String type) {
    resourceType.value = type;
    searchC.clear();
  }

  // Setter for the state filter (the listener does the rest)
  void changeStateFilter(String state) {
    selectedStateFilter.value = state;
  }

  // Important: Dispose method to release resources (call when destroying the widget)
  void dispose() {
    searchC.removeListener(_updateStream);
    selectedStateFilter.removeListener(_updateStream);
    resourceType.removeListener(_updateStream);

    resourceType.dispose();
    selectedStateFilter.dispose();
    filteredResourcesStream.dispose();

    statsNotifier.dispose();
    searchC.dispose();
    nameController.dispose();
    tarifController.dispose();
    specs.dispose();
    review.dispose();
    usage.dispose();
    totalUsage.dispose();
    email.dispose();
    habilities.dispose();
  }

  // VALIDATION METHODS AND PROPERTIES AND ACTIONS

  void clearResourceForm() {
    nameController.clear();
    kindController.clear();
    tarifController.clear();
    specs.clear();
    review.clear();
    usage.clear();
    totalUsage.clear();
    email.clear();
    habilities.clear();

    labC = null;
    stateC = null;
    departmentC = null;
    conditionC = null;
    lastDate = null;
    nextDate = null;
    filter = null;
  }

  Future<String> getCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'GUEST';
    }

    try {
      final idTokenResult = await user.getIdTokenResult(true);

      // AÑADIDO: DEBUG para ver si el token tiene el claim
      debugPrint("Claims del Token: ${idTokenResult.claims}");
      final role = idTokenResult.claims?['role'] ?? 'USER';
      return role.toString().toUpperCase();
    } catch (e) {
      debugPrint("Error fetching user role from token: $e");
      return 'USER';
    }
  }

  Future<void> fetchAndCalculateStats() async {
    int totalPersonnel = 0;
    int availablePersonnel = 0;
    int totalEquipment = 0;
    int availableEquipment = 0;
    int inMaintenance = 0;
    double currentUsageSum = 0.0;
    double totalUsageCapacitySum = 0.0;

    try {
      final humanSnapshot = await FirebaseFirestore.instance
          .collection('human-resources')
          .get();

      totalPersonnel = humanSnapshot.docs.length;
      for (var doc in humanSnapshot.docs) {
        final data = doc.data();
        final state = data['state'] as String? ?? 'N/A';

        final usage = (data['use'] as num?)?.toDouble() ?? 0.0;
        final totalUsageCapacity =
            (data['totalUsage'] as num?)?.toDouble() ?? 0.0;

        if (state == 'Disponible' || state == 'Parcialmente Disponible') {
          availablePersonnel++;
        }

        currentUsageSum += usage;
        totalUsageCapacitySum += totalUsageCapacity;
      }

      final materialSnapshot = await FirebaseFirestore.instance
          .collection('material-resources')
          .get();

      totalEquipment = materialSnapshot.docs.length;
      for (var doc in materialSnapshot.docs) {
        final data = doc.data();
        final state = data['state'] as String? ?? 'N/A';

        if (state == 'Disponible') {
          availableEquipment++;
        }

        if (state == 'Mantenimiento') {
          inMaintenance++;
        }
      }

      double averageUtilization = 0.0;
      if (totalUsageCapacitySum > 0) {
        averageUtilization = currentUsageSum / totalUsageCapacitySum;
      }

      final newStats = ResourceStats(
        availablePersonnel: availablePersonnel,
        totalPersonnel: totalPersonnel,
        availableEquipment: availableEquipment,
        totalEquipment: totalEquipment,
        averageUtilization: averageUtilization.clamp(0.0, 1.0),
        inMaintenance: inMaintenance,
      );

      statsNotifier.value = newStats;
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  final statsNotifier = ValueNotifier<ResourceStats>(
    ResourceStats(
      availablePersonnel: 0,
      totalPersonnel: 0,
      availableEquipment: 0,
      totalEquipment: 0,
      averageUtilization: 0.0,
      inMaintenance: 0,
    ),
  );

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
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
    if (value == null || value.isEmpty) {
      // Aceptamos que esté vacío si no es requerido, o se añade la validación de vacío aquí
      return 'El campo Tarifa esta vacio'; // O simplemente 'return null;' si es opcional
    }

    try {
      double? tarifa = double.tryParse(value);
      if (tarifa == null) {
        return 'No has puesto un numero válido';
      } else if (tarifa < 0) {
        return 'El número no puede ser negativo';
      } else {
        debugPrint(value);
        return null;
      }
    } catch (e) {
      debugPrint('Error al parsear número: $e');
      return 'No has puesto un número válido';
    }
  }

  String? validateHabilities(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo Habilidades esta vacio';
    }
    return null;
  }

  String? validateSpecs(String? value) {
    if (value == null || value.trim().isEmpty) {
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
    return validateDepartment() == null &&
        validateHabilities(habilities.text) == null &&
        validateEmail(email.text) == null &&
        validateState() == null &&
        validateTarif(tarifController.text) == null &&
        validateTarif(totalUsage.text) == null &&
        validateLab() == null &&
        validateName(nameController.text) == null;
  }

  bool validateMRFields() {
    return validateLastDate() == null &&
        validateNextDate() == null &&
        validateState() == null &&
        validateSpecs(specs.text) == null &&
        validateLab() == null &&
        validateName(nameController.text) == null;
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
              'tarif': double.tryParse(tarifController.text) ?? 0.0,
              'use': 0, // El uso inicial debe ser 0.
              'totalUsage': int.tryParse(totalUsage.text) ?? 0,
              'habilities': habilities.text,
              'department': departmentC,
            });
        await fetchAndCalculateStats();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Recurso humano creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al crear recurso humano: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
    }
  }

  Future<void> createMResource(BuildContext context) async {
    if (validateMRFields() == true) {
      try {
        await FirebaseFirestore.instance
            .collection("material-resources")
            .doc()
            .set({
              'name': nameController.text,
              'state': stateC,
              'projects': null,
              'lab': labC,
              'tarif': double.tryParse(tarifController.text) ?? 0.0,
              'condition': conditionC,
              'lastDate': lastDate!.toIso8601String(),
              'nextDate': nextDate!.toIso8601String(),
              'specs': specs.text,
            });
        await fetchAndCalculateStats();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Recurso material creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al crear recurso material: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
    }
  }

  Future<List> getHResources() async {
    List<Map> lista = List.empty(growable: true);
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

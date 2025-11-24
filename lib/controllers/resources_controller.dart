import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/resources_model.dart';

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
  final descripcionassign = TextEditingController();

  final ValueNotifier<String> resourceType = ValueNotifier<String>('Humanos');
  final ValueNotifier<String> selectedStateFilter = ValueNotifier<String>(
    'Todos los estados',
  );
  final searchC = TextEditingController();

  late final ValueNotifier<Stream<List<ResourcesModel>>>
  filteredResourcesStream;

  String? labC;
  String? stateC;
  String? departmentC;
  String? conditionC;
  DateTime? lastDate;
  DateTime? nextDate;
  String? filter;
  String? priority;
  String? proyecto;
  String? resource;
  final _firestore = FirebaseFirestore.instance;

  ResourcesController() {
    filteredResourcesStream = ValueNotifier(_buildResourceStream());

    searchC.addListener(_updateStream);
    selectedStateFilter.addListener(_updateStream);
    resourceType.addListener(_updateStream);
  }

  Future<void> deleteResource(String resourceId) async {
    String collection = resourceType.value == 'Humanos'
        ? 'human-resources'
        : 'material-resources';

    try {
      final role = await getCurrentUserRole();
      if (role != 'ADMIN' && role != 'COORDINATOR') {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message:
              'No tienes permisos suficientes (rol: $role) para eliminar este recurso.',
        );
      }

      await _firestore.collection(collection).doc(resourceId).delete();

      debugPrint('Recurso $resourceId eliminado con éxito.');

      await fetchAndCalculateStats();
    } catch (e) {
      debugPrint('Error al eliminar el recurso: $e');
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
            return {'id': doc.id, 'data': doc.data() as Map<String, dynamic>};
          })
          .where((item) {
            final data = item['data'] as Map<String, dynamic>;

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
            final id = item['id'] as String;

            if (resourceType.value == 'Humanos') {
              return HumanResources(
                id: id,
                review: data['review'] ?? '',
                usage: (data['use'] as num? ?? 0).toInt(),
                totalUsage: (data['totalUsage'] as num? ?? 0).toInt(),
                email: data['mail'] ?? '',
                habilities: data['habilities'] ?? '',
                department: data['department'] ?? '',
                projects: (data['projects'] as List<dynamic>? ?? const [])
                    .map((e) => e.toString())
                    .toList(),
                name: data['name'] ?? 'N/A',
                state: data['state'] ?? 'N/A',
                lab: data['lab'] ?? 'N/A',
                kind: 'Humano',
                hourlyTarif: (data['tarif'] as num? ?? 0).toDouble(),
              );
            } else {
              return MaterialResource(
                id: id,
                lastMaintenance: data['lastDate'] != null
                    ? DateTime.tryParse(data['lastDate']) ?? DateTime(2000)
                    : DateTime(2000),
                nextMaintenance: data['nextDate'] != null
                    ? DateTime.tryParse(data['nextDate']) ?? DateTime(2000)
                    : DateTime(2000),
                specs: data['specs'] ?? '',
                projects: (data['projects'] as List<dynamic>? ?? const [])
                    .map((e) => e.toString())
                    .toList(),
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

  void _updateStream() {
    filteredResourcesStream.value = _buildResourceStream();
  }

  void changeResourceType(String type) {
    resourceType.value = type;
    searchC.clear();
  }

  void changeStateFilter(String state) {
    selectedStateFilter.value = state;
  }

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
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      final role = data['role'];
      return role;
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

  String? validateLab() => labC == null ? 'Selecciona un laboratorio' : null;

  String? validateCondition() =>
      conditionC == null ? 'Selecciona su condición' : null;

  String? validateState() =>
      stateC == null ? 'Selecciona el estado del recurso' : null;

  String? validateDepartment() =>
      departmentC == null ? 'Selecciona su departamento' : null;

  String? validatePriority() =>
      priority == null ? 'Selecciona la prioridad' : null;

  String? validateProject() =>
      priority == null ? 'Selecciona la prioridad' : null;

  String? validateTarif(String? value) {
    try {
      if (value != null && value.isNotEmpty) {
        int tarifa = int.parse(value);
        if (tarifa < 0) {
          return 'Numero negativo';
        } else {
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
    if (validateHRFields() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
    }

    final String correo = email.text.trim();
    final double tarifa = double.tryParse(tarifController.text) ?? 0.0;
    final int usototal = int.tryParse(totalUsage.text) ?? 0;
    final String laboratorio = labC!;
    final String estado = stateC!;
    final String departamento = departmentC!;
    final String habilidades = habilities.text;

    try {
      final QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: correo)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data() as Map<String, dynamic>;
        final String? nombre = data['name'] as String?;

        await FirebaseFirestore.instance.collection("human-resources").add({
          'name': nombre,
          'state': estado,
          'lab': laboratorio,
          'projects': [],
          'mail': correo,
          'tarif': tarifa,
          'use': 0,
          'totalUsage': usototal,
          'habilities': habilidades,
          'department': departamento,
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
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'El email "$correo" no está registrado como usuario válido.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear recurso humano: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              'projects': [],
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
        const SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getHResources() async {
    final List<Map<String, dynamic>> lista = [];
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

  Future<List<String>> nombreProyectos() async {
    List<String> nombres = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('name') && data['name'] is String) {
          nombres.add(data['name']);
        }
      }
      return nombres;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> nombreRecursos() async {
    List<String> nombres = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('human-resources')
          .get();
      QuerySnapshot snapshot2 = await FirebaseFirestore.instance
          .collection('material-resources')
          .get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name')) {
          nombres.add(data['name']);
        }
      }
      for (var doc in snapshot2.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name')) {
          nombres.add(data['name']);
        }
      }
      return nombres;
    } catch (e) {
      return [];
    }
  }

  Future<void> assignProject(
    String? proyecto,
    String? recurso,
    String? use,
    BuildContext context,
  ) async {
    try {
      if (proyecto == null || recurso == null || use == null || use.isEmpty) {
        throw Exception('Datos incompletos para la asignación.');
      }

      final int uso = int.parse(use);
      final String project = proyecto;
      final String resource = recurso;

      final List<String> lista = <String>[project];

      final humanSnap = await FirebaseFirestore.instance
          .collection('human-resources')
          .where('name', isEqualTo: resource)
          .get();

      final materialSnap = await FirebaseFirestore.instance
          .collection('material-resources')
          .where('name', isEqualTo: resource)
          .get();

      // Caso: es recurso material
      if (humanSnap.size == 0) {
        if (materialSnap.size == 0) {
          throw Exception('No se encontró el recurso seleccionado.');
        }

        for (final doc in materialSnap.docs) {
          if (doc.exists) {
            await FirebaseFirestore.instance
                .collection('material-resources')
                .doc(doc.id)
                .set({
                  'projects': FieldValue.arrayUnion(lista),
                }, SetOptions(merge: true));
          }
        }
      } else {
        // Caso: recurso humano
        bool updated = false;

        for (final doc in humanSnap.docs) {
          if (doc.exists) {
            final data = doc.data();
            if (data.containsKey('name')) {
              final int currentUse = (data['use'] as num? ?? 0).toInt();
              final int total = (data['totalUsage'] as num? ?? 0).toInt();

              if (total <= 0) {
                throw Exception(
                  'El recurso no tiene horas totales configuradas.',
                );
              }

              if (currentUse + uso > total) {
                throw Exception(
                  'Overflow en horas: las horas asignadas superan el total disponible.',
                );
              }

              await FirebaseFirestore.instance
                  .collection('human-resources')
                  .doc(doc.id)
                  .update({
                    'projects': FieldValue.arrayUnion(lista),
                    'use': FieldValue.increment(uso),
                  });

              updated = true;
            }
          }
        }

        if (!updated) {
          throw Exception('No se pudo actualizar el recurso humano.');
        }
      }

      await fetchAndCalculateStats();
      _updateStream();
    } catch (e) {
      debugPrint('Error en assignProject: $e');
      rethrow;
    }
  }

  void cargarHResource(HumanResources resource) {
    nameController.text = resource.name;
    email.text = resource.email;
    labC = resource.lab;
    stateC = resource.state;
    tarifController.text = resource.hourlyTarif.toString();
    totalUsage.text = resource.totalUsage.toString();
    habilities.text = resource.habilities;
    departmentC = resource.department;
  }

  void cargarMResource(MaterialResource resource) {
    nameController.text = resource.name;
    conditionC = resource.condition;
    labC = resource.lab;
    stateC = resource.state;
    tarifController.text = resource.hourlyTarif.toString();
    lastDate = resource.lastMaintenance;
    nextDate = resource.nextMaintenance;
    specs.text = resource.specs;
  }

  Future<void> modifyMResource(
    BuildContext context,
    MaterialResource mR,
  ) async {
    if (validateMRFields() == true) {
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection('material-resources')
            .where('name', isEqualTo: mR.name)
            .get();

        for (var doc in snap.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['name'] == mR.name && data['condition'] == mR.condition) {
            await FirebaseFirestore.instance
                .collection("material-resources")
                .doc(doc.id)
                .update({
                  'name': nameController.text,
                  'state': stateC,
                  'lab': labC,
                  'tarif': double.tryParse(tarifController.text) ?? 0.0,
                  'condition': conditionC,
                  'lastDate': lastDate!.toIso8601String(),
                  'nextDate': nextDate!.toIso8601String(),
                  'specs': specs.text,
                });
          }
        }
        await fetchAndCalculateStats();
        _updateStream();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Recurso material modificado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al modificar recurso material: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrige los errores antes de continuar')),
      );
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/tasks_model.dart';

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

class TaskController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TaskColumn> _columns = [];
  List<Task> _tasks = [];
  String? _currentProjectId;

  TaskController() {
    _initializeColumns();
    //_loadTasks();
  }

  List<TaskColumn> get columns => _columns;
  List<Task> get tasks => _tasks;
  String? get currentProjectId => _currentProjectId;

  void _setCurrentProject(String projectId) {
    _currentProjectId = projectId;
    _loadTasks();
    notifyListeners();
  }

  void _initializeColumns() {
    _columns = [
      TaskColumn(name: 'Pendiente', color: Colors.grey),
      TaskColumn(name: 'En Progreso', color: Colors.blue),
      TaskColumn(name: 'En Revisión', color: Colors.orange),
      TaskColumn(name: 'Completado', color: Colors.green),
    ];
  }

  Future<void> _loadTasks() async {
    if (_currentProjectId == null) {
      print('⚠️ No hay projectId establecido');
      return;
    }
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .get();

      _tasks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          projectType: data['projectType'] ?? '',
          assignee: data['assignee'] ?? '',
          priority: _stringToPriority(data['priority'] ?? 'media'),
          status: _stringToStatus(data['status'] ?? 'pendiente'),
          estimatedHours: (data['estimatedHours'] ?? 0).toDouble(),
          dueTime: data['dueDate'] != null
              ? DateTime.parse(data['dueDate'])
              : null,
          tags: List<String>.from(data['tags'] ?? []),
          projectId: _currentProjectId!, // ← NUEVO
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('❌ Error cargando tareas: $e');
    }
  }

  ValidationResult validateTask(Task task) {
    final errors = <String, String>{};

    // TITLE VALIDATION
    if (task.title.trim().isEmpty) {
      errors['title'] = 'El título es requerido';
    } else if (task.title.trim().length < 3) {
      errors['title'] = 'El título debe tener al menos 3 caracteres';
    }

    // ESTIMATED HOURS VALIDATION
    if (task.estimatedHours == 0) {
      errors['hours'] = 'Las horas estimadas son requeridas';
    } else if (task.estimatedHours < 0) {
      errors['hours'] = 'Las horas deben ser mayores a 0';
    }

    // VDESCRIPTION VALIDATION
    if (task.description.length > 500) {
      errors['description'] = 'La descripción no puede exceder 500 caracteres';
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  Future<void> addTask(Task task) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }

    final validation = validateTask(task);
    if (!validation.isValid) {
      throw Exception('Datos inválidos: ${validation.errors}');
    }
    try {
      print('🔄 INTENTANDO GUARDAR EN FIRESTORE...');
      print('📝 Título: ${task.title}');
      print('🏷️ Proyecto: ${task.projectType}');
      print('📂 Project ID: ${task.projectId}');

      final DocumentReference docRef = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .add({
            'title': task.title,
            'description': task.description,
            'projectType': task.projectType,
            'assignee': task.assignee,
            'priority': _priorityToString(task.priority),
            'status': _statusToString(task.status),
            'estimatedHours': task.estimatedHours,
            'dueDate': task.dueTime?.toIso8601String(),
            'tags': task.tags,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print(
        '✅ TAREA GUARDADA EN: projects/$_currentProjectId/tasks/${docRef.id}',
      );

      _tasks.add(
        Task(
          id: docRef.id,
          title: task.title,
          description: task.description,
          projectType: task.projectType,
          assignee: task.assignee,
          priority: task.priority,
          status: task.status,
          estimatedHours: task.estimatedHours,
          dueTime: task.dueTime,
          tags: task.tags,
          projectId: task.projectId,
        ),
      );
      notifyListeners();
    } catch (e) {
      print('❌ ERROR EN FIRESTORE: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final querySnapshot = await _firestore.collection('projects').get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc.data()['name'] ?? 'Sin nombre'};
      }).toList();
    } catch (e) {
      print('❌ Error cargando proyectos: $e');
      return [];
    }
  }

  Priority _stringToPriority(String priority) {
    switch (priority) {
      case 'alta':
        return Priority.alta;
      case 'media':
        return Priority.media;
      case 'baja':
        return Priority.baja;
      default:
        return Priority.media;
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.alta:
        return 'alta';
      case Priority.media:
        return 'media';
      case Priority.baja:
        return 'baja';
    }
  }

  Status _stringToStatus(String status) {
    switch (status) {
      case 'pendiente':
        return Status.pendiente;
      case 'enProgreso':
        return Status.enProgreso;
      case 'enRevision':
        return Status.enRevision;
      case 'completado':
        return Status.completado;
      default:
        return Status.pendiente;
    }
  }

  String _statusToString(Status status) {
    switch (status) {
      case Status.pendiente:
        return 'pendiente';
      case Status.enProgreso:
        return 'enProgreso';
      case Status.enRevision:
        return 'enRevision';
      case Status.completado:
        return 'completado';
    }
  }

  void addColumn(TaskColumn column) {
    _columns.add(column);
    notifyListeners();
  }

  void removeColumn(TaskColumn column) {
    _columns.remove(column);
    notifyListeners();
  }

  List<Task> getTasksByColumn(String columnName) {
    final statusMap = {
      'Pendiente': Status.pendiente,
      'En Progreso': Status.enProgreso,
      'En Revisión': Status.enRevision,
      'Completado': Status.completado,
    };

    final status = statusMap[columnName];
    if (status != null) {
      return _tasks.where((task) => task.status == status).toList();
    }

    return [];
  }
}

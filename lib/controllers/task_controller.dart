import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import '../models/tasks_model.dart';

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

class TaskController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<TaskColumn> _columns = [];
  List<Task> _tasks = [];
  String? _currentProjectId;
  List<Map<String, dynamic>> _availableProjects = [];
  Project? _currentProject;
  Map<String, dynamic>? _currentProjectData;

  TaskController() {
    _initializeColumns();
    //_loadTasks();
  }

  //GETTERS
  List<TaskColumn> get columns => _columns;
  List<Task> get tasks => _tasks;
  String? get currentProjectId => _currentProjectId;
  Project? get currentProject => _currentProject;
  List<Map<String, dynamic>> get availableProjects => _availableProjects;
  Map<String, dynamic>? get currentProjectData => _currentProjectData;

  //INITIALIZE DEFAULT COLUMNS
  void _initializeColumns() {
    _columns = [
      TaskColumn(name: 'Pendiente', color: Colors.grey),
      TaskColumn(name: 'En Progreso', color: Colors.blue),
      TaskColumn(name: 'En Revisión', color: Colors.orange),
      TaskColumn(name: 'Completado', color: Colors.green),
    ];
  }

  //LOAD TASKS
  Future<void> _loadTasks() async {
    if (_currentProjectId == null) {
      //print(' No hay projectId establecido');
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
          projectId: _currentProjectId!,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      //print('Error cargando tareas: $e');
    }
  }

  //VALIDATE REQUIRED FIELDS
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

  //UPDATE TASK STATUS IN FIRESTORE
  Future<void> updateTaskStatus(String taskId, Status newStatus) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }

    try {
      await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .doc(taskId)
          .update({
            'status': _statusToString(newStatus),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Future.microtask(() {
        final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          final oldTask = _tasks[taskIndex];
          _tasks[taskIndex] = Task(
            id: oldTask.id,
            title: oldTask.title,
            description: oldTask.description,
            projectType: oldTask.projectType,
            assignee: oldTask.assignee,
            priority: oldTask.priority,
            status: newStatus,
            estimatedHours: oldTask.estimatedHours,
            dueTime: oldTask.dueTime,
            tags: oldTask.tags,
            projectId: oldTask.projectId,
          );

          notifyListeners();
        }
      });
    } catch (e) {
      //print('Error actualizando tarea: $e');
      rethrow;
    }
  }

  //UPDATE TASK DETAILS IN FIRESTORE
  Future<void> updateTask(Task updatedTask) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }

    try {
      await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .doc(updatedTask.id)
          .update({
            'title': updatedTask.title,
            'description': updatedTask.description,
            'projectType': updatedTask.projectType,
            'assignee': updatedTask.assignee,
            'priority': _priorityToString(updatedTask.priority),
            'status': _statusToString(updatedTask.status),
            'estimatedHours': updatedTask.estimatedHours,
            'dueDate': updatedTask.dueTime?.toIso8601String(),
            'tags': updatedTask.tags,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      print('Error actualizando tarea: $e');
      rethrow;
    }
  }

  //ADD TASK AND SAVE IN FIRESTORE
  Future<void> addTask(Task task) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }

    final validation = validateTask(task);
    if (!validation.isValid) {
      throw Exception('Datos inválidos: ${validation.errors}');
    }
    try {
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
      // print('ERROR EN FIRESTORE: $e');
      rethrow;
    }
  }

  //DELETE TASK AND SAVE IN FIRESTORE
  Future<void> deleteTask(String taskId) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }
    try {
      await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .doc(taskId)
          .delete();

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();

      // print('Tarea eliminada correctamente');
    } catch (e) {
      //
      rethrow;
    }
  }

  //GET AVAILABLE PROJECTS IN FIRESTORE
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final querySnapshot = await _firestore.collection('projects').get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc.data()['name'] ?? 'Sin nombre'};
      }).toList();
    } catch (e) {
      //
      return [];
    }
  }

  //POSSIBLES PROJECTS
  Future<void> setCurrentProject(String projectId) async {
    _currentProjectId = projectId;

    try {
      final projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();

      if (projectDoc.exists) {
        _currentProjectData = projectDoc.data();

        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          print('Usuario no autenticado');
          _tasks = [];
          notifyListeners();
          return;
        }

        final visibleTo = List<String>.from(
          _currentProjectData?['visibleTo'] ?? [],
        );
        final ownerId = _currentProjectData?['ownerId'];

        final hasAccess =
            visibleTo.contains(currentUser.uid) || ownerId == currentUser.uid;

        if (hasAccess) {
          print('Usuario tiene acceso al proyecto');
          await _loadColumns();
          _loadTasks();
        } else {
          print(' Usuario NO tiene acceso al proyecto');
          _tasks = [];
          _showAccessDeniedMessage();
        }
      } else {
        print(' Proyecto no encontrado: $projectId');
        _currentProjectData = null;
        _tasks = [];
      }

      notifyListeners();
    } catch (e) {
      //print('Error cargando proyecto: $e');
      _currentProjectData = null;
      _tasks = [];
      notifyListeners();
    }
  }

  void _showAccessDeniedMessage() {
    print(' No tienes acceso a este proyecto');
  }

  //LOAD PROJECTS (USER ACCESS)
  Future<void> loadAvailableProjects() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print(' Usuario no autenticado');
        _availableProjects = [];
        notifyListeners();
        return;
      }

      print('🔄 Cargando proyectos para usuario: ${currentUser.uid}');
      final querySnapshot = await _firestore.collection('projects').get();

      _availableProjects = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final visibleTo = List<String>.from(data['visibleTo'] ?? []);
            final ownerId = data['ownerId'];

            return visibleTo.contains(currentUser.uid) ||
                ownerId == currentUser.uid;
          })
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Sin nombre',
              'consultingType': data['consultingType'] ?? 'Proyecto',
              'ownerId': data['ownerId'],
              'visibleTo': List<String>.from(data['visibleTo'] ?? []),
            };
          })
          .toList();

      print('✅ Proyectos con acceso: ${_availableProjects.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando proyectos: $e');
      _availableProjects = [];
    }
  }

  //ADD COLUMN
  void addColumn(TaskColumn column) {
    _columns.add(column);
    _saveColumns();
    notifyListeners();
  }

  //DELETE COLUMN
  void removeColumn(TaskColumn column) {
    _columns.remove(column);
    _saveColumns();
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

  //LOAD CUSTOM COLUMNS
  Future<void> _loadColumns() async {
    if (_currentProjectId == null) return;

    try {
      final columnsDoc = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('metadata')
          .doc('columns')
          .get();

      if (columnsDoc.exists) {
        final data = columnsDoc.data();
        final columnsData = data?['columns'] as List?;

        if (columnsData != null) {
          _columns = columnsData.map((col) {
            return TaskColumn(
              name: col['name'] ?? '',
              color: _parseColor(col['color']),
            );
          }).toList();
          print('Columnas cargadas: ${_columns.length}');
        }
      } else {
        _initializeDefaultColumns();
        _saveColumns();
      }

      notifyListeners();
    } catch (e) {
      print('Error cargando columnas: $e');
      _initializeDefaultColumns();
    }
  }

  //SAVE COLUMNS
  Future<void> _saveColumns() async {
    if (_currentProjectId == null) return;

    try {
      final columnsData = _columns.map((col) {
        return {'name': col.name, 'color': _colorToString(col.color)};
      }).toList();

      await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('metadata')
          .doc('columns')
          .set({
            'columns': columnsData,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('Columnas guardadas: ${_columns.length}');
    } catch (e) {
      print('Error guardando columnas: $e');
    }
  }

  //DEFAULT COLUMNS
  void _initializeDefaultColumns() {
    _columns = [
      TaskColumn(name: 'Pendiente', color: Colors.grey),
      TaskColumn(name: 'En Progreso', color: Colors.blue),
      TaskColumn(name: 'En Revisión', color: Colors.orange),
      TaskColumn(name: 'Completado', color: Colors.green),
    ];
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

  Color _parseColor(dynamic colorData) {
    if (colorData is int) {
      return Color(colorData);
    } else if (colorData is String) {
      final buffer = StringBuffer();
      buffer.write(colorData.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    return Colors.grey;
  }

  String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}

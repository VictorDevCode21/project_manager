import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/tasks_model.dart';

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

  void _setCurrentProjects(String projectId) {
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
    if (_currentProjectId == null) ;
    print('⚠️ No hay projectId establecido');
    return;
  }

  Future<void> addTask(Task task) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
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

      _tasks.add(task.copyWith(id: docRef.id));
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

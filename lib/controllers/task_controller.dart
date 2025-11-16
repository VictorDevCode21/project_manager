import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

/// Represents the result of a task validation process.
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

/// Controller responsible for loading, creating and updating tasks
/// inside a project. It also manages task board columns and project members.
class TaskController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskColumn> _columns = <TaskColumn>[];
  List<Task> _tasks = <Task>[];
  String? _currentProjectId;
  List<Map<String, dynamic>> _availableProjects = <Map<String, dynamic>>[];
  Project? _currentProject;
  Map<String, dynamic>? _currentProjectData;

  /// Project members visible in the current project.
  /// Each item has:
  /// { 'id': '<userId>', 'name': '<display name>' }
  List<Map<String, String>> _projectMembers = <Map<String, String>>[];

  TaskController() {
    _initializeDefaultColumns();
  }

  // ===== PUBLIC GETTERS =====

  List<TaskColumn> get columns => _columns;

  List<Task> get tasks => _tasks;

  String? get currentProjectId => _currentProjectId;

  Project? get currentProject => _currentProject;

  List<Map<String, dynamic>> get availableProjects => _availableProjects;

  Map<String, dynamic>? get currentProjectData => _currentProjectData;

  /// Safe getter for project members.
  List<Map<String, String>> get projectMembers => _projectMembers;

  // ===== INTERNAL LOADERS =====

  /// Loads all tasks for the currently selected project.
  Future<void> _loadTasks() async {
    if (_currentProjectId == null) {
      return;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .get();

      _tasks = querySnapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        final Map<String, dynamic> data = doc.data();

        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          projectType: data['projectType'] ?? '',
          assignee: data['assignee'] ?? '',
          priority: _stringToPriority(
            (data['priority'] ?? 'MEDIUM').toString(),
          ),
          status: _stringToStatus((data['status'] ?? 'pendiente').toString()),
          estimatedHours: (data['estimatedHours'] ?? 0).toDouble(),
          dueTime: data['dueDate'] != null
              ? DateTime.parse(data['dueDate'] as String)
              : null,
          tags: List<String>.from(data['tags'] ?? <String>[]),
          projectId: _currentProjectId!,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _tasks = <Task>[];
      notifyListeners();
    }
  }

  /// Loads project members for the given project from
  /// `projects/{projectId}/members`.
  ///
  /// Flexible fields:
  /// - userId: String (preferred)
  /// - name / displayName / fullName / email: String (for display)
  Future<void> _loadProjectMembers(String projectId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> membersSnapshot =
          await _firestore
              .collection('projects')
              .doc(projectId)
              .collection('members')
              .get();

      _projectMembers = membersSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();

            final String id = (data['userId'] ?? doc.id).toString();
            final String name =
                (data['name'] ??
                        data['displayName'] ??
                        data['fullName'] ??
                        data['email'] ??
                        'Sin nombre')
                    .toString();

            return <String, String>{'id': id, 'name': name};
          })
          .where((Map<String, String> member) {
            return (member['id'] ?? '').isNotEmpty;
          })
          .toList();

      debugPrint(
        '[TaskController] Loaded ${_projectMembers.length} members for project $projectId',
      );
    } catch (e) {
      debugPrint('[TaskController] Error loading project members: $e');
      _projectMembers = <Map<String, String>>[];
    }

    notifyListeners();
  }

  // ===== VALIDATION =====

  /// Validates required fields for a task before persisting it.
  ValidationResult validateTask(Task task) {
    final Map<String, String> errors = <String, String>{};
    final RegExp onlyDigitsRegex = RegExp(r'^\d+$');

    // Title validation
    final String titleTrimmed = task.title.trim();
    if (titleTrimmed.isEmpty) {
      errors['title'] = 'El título es requerido';
    } else if (titleTrimmed.length < 3) {
      errors['title'] = 'El título debe tener al menos 3 caracteres';
    } else if (onlyDigitsRegex.hasMatch(titleTrimmed)) {
      errors['title'] = 'El título no puede ser solo numérico';
    }

    // Estimated hours validation
    if (task.estimatedHours == 0) {
      errors['hours'] = 'Las horas estimadas son requeridas';
    } else if (task.estimatedHours < 0) {
      errors['hours'] = 'Las horas deben ser mayores a 0';
    } else if (task.estimatedHours % 1 != 0) {
      errors['hours'] = 'Las horas deben ser un número entero (sin decimales)';
    }

    // Description validation
    final String descriptionTrimmed = task.description.trim();
    if (descriptionTrimmed.length > 500) {
      errors['description'] = 'La descripción no puede exceder 500 caracteres';
    } else if (descriptionTrimmed.isNotEmpty &&
        onlyDigitsRegex.hasMatch(descriptionTrimmed)) {
      errors['description'] = 'La descripción no puede ser solo numérica';
    }

    // Assignee validation
    if (task.assignee.trim().isEmpty) {
      errors['assignee'] = 'El asignado es requerido';
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ===== TASK MUTATIONS =====

  /// Updates only the status of a task, both in Firestore and local cache.
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
          .update(<String, dynamic>{
            'status': _statusToString(newStatus),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Future<void>.microtask(() {
        final int taskIndex = _tasks.indexWhere(
          (Task task) => task.id == taskId,
        );
        if (taskIndex != -1) {
          final Task oldTask = _tasks[taskIndex];
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
      rethrow;
    }
  }

  /// Updates all editable fields of an existing task.
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
          .update(<String, dynamic>{
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

      final int taskIndex = _tasks.indexWhere(
        (Task task) => task.id == updatedTask.id,
      );
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new task in Firestore and updates local state.
  Future<void> addTask(Task task) async {
    if (_currentProjectId == null) {
      throw Exception('No hay proyecto seleccionado');
    }

    final ValidationResult validation = validateTask(task);
    if (!validation.isValid) {
      throw Exception('Datos inválidos: ${validation.errors}');
    }

    try {
      final DocumentReference<Map<String, dynamic>> docRef = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('tasks')
          .add(<String, dynamic>{
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
      rethrow;
    }
  }

  /// Deletes a task from Firestore and local cache.
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

      _tasks.removeWhere((Task task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ===== PROJECTS MANAGEMENT =====

  /// Returns all projects in Firestore, without access filtering.
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('projects')
          .get();
      return querySnapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        return <String, dynamic>{
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Sin nombre',
        };
      }).toList();
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Sets the current project, checks access permissions,
  /// loads columns, members and tasks.
  Future<void> setCurrentProject(String projectId) async {
    _currentProjectId = projectId;

    try {
      final DocumentSnapshot<Map<String, dynamic>> projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();

      if (projectDoc.exists) {
        _currentProjectData = projectDoc.data();

        final User? currentUser = _auth.currentUser;
        if (currentUser == null) {
          _tasks = <Task>[];
          _projectMembers = <Map<String, String>>[];
          notifyListeners();
          return;
        }

        final List<String> visibleTo = List<String>.from(
          _currentProjectData?['visibleTo'] ?? <String>[],
        );
        final String? ownerId = _currentProjectData?['ownerId'] as String?;

        final bool hasAccess =
            visibleTo.contains(currentUser.uid) || ownerId == currentUser.uid;

        if (hasAccess) {
          await _loadColumns();
          await _loadProjectMembers(projectId);
          await _loadTasks();
        } else {
          _tasks = <Task>[];
          _projectMembers = <Map<String, String>>[];
          _showAccessDeniedMessage();
        }
      } else {
        _currentProjectData = null;
        _tasks = <Task>[];
        _projectMembers = <Map<String, String>>[];
      }

      notifyListeners();
    } catch (e) {
      _currentProjectData = null;
      _tasks = <Task>[];
      _projectMembers = <Map<String, String>>[];
      notifyListeners();
    }
  }

  /// Simple log helper when user has no access.
  void _showAccessDeniedMessage() {
    debugPrint('User does not have access to this project.');
  }

  /// Loads all projects where the current user is included in `visibleTo`
  /// or is the project owner.
  Future<void> loadAvailableProjects() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _availableProjects = <Map<String, dynamic>>[];
        notifyListeners();
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('projects')
          .get();

      _availableProjects = querySnapshot.docs
          .where((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            final List<String> visibleTo = List<String>.from(
              data['visibleTo'] ?? <String>[],
            );
            final String? ownerId = data['ownerId'] as String?;

            return visibleTo.contains(currentUser.uid) ||
                ownerId == currentUser.uid;
          })
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            return <String, dynamic>{
              'id': doc.id,
              'name': data['name'] ?? 'Sin nombre',
              'consultingType': data['consultingType'] ?? 'Proyecto',
              'ownerId': data['ownerId'],
              'visibleTo': List<String>.from(data['visibleTo'] ?? <String>[]),
            };
          })
          .toList();

      notifyListeners();
    } catch (e) {
      _availableProjects = <Map<String, dynamic>>[];
      notifyListeners();
    }
  }

  // ===== COLUMNS MANAGEMENT =====

  /// Adds a new column to the local list and persists it.
  void addColumn(TaskColumn column) {
    _columns.add(column);
    _saveColumns();
    notifyListeners();
  }

  /// Removes a column from the local list and persists the change.
  void removeColumn(TaskColumn column) {
    _columns.remove(column);
    _saveColumns();
    notifyListeners();
  }

  /// Returns tasks matching the given column name based on their status.
  List<Task> getTasksByColumn(String columnName) {
    final Map<String, Status> statusMap = <String, Status>{
      'Pendiente': Status.pendiente,
      'En Progreso': Status.enProgreso,
      'En Revisión': Status.enRevision,
      'Completado': Status.completado,
    };

    final Status? status = statusMap[columnName];
    if (status != null) {
      return _tasks.where((Task task) => task.status == status).toList();
    }

    return <Task>[];
  }

  /// Loads custom columns for the current project from Firestore.
  Future<void> _loadColumns() async {
    if (_currentProjectId == null) return;

    try {
      final DocumentSnapshot<Map<String, dynamic>> columnsDoc = await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('metadata')
          .doc('columns')
          .get();

      if (columnsDoc.exists) {
        final Map<String, dynamic>? data = columnsDoc.data();
        final List<dynamic>? columnsData = data?['columns'] as List<dynamic>?;

        if (columnsData != null) {
          _columns = columnsData.map((dynamic col) {
            final Map<String, dynamic> colMap = col as Map<String, dynamic>;
            return TaskColumn(
              name: colMap['name'] as String? ?? '',
              color: _parseColor(colMap['color']),
            );
          }).toList();
        }
      } else {
        _initializeDefaultColumns();
        _saveColumns();
      }

      notifyListeners();
    } catch (e) {
      _initializeDefaultColumns();
      notifyListeners();
    }
  }

  /// Persists current columns configuration into Firestore.
  Future<void> _saveColumns() async {
    if (_currentProjectId == null) return;

    try {
      final List<Map<String, dynamic>> columnsData = _columns.map((
        TaskColumn col,
      ) {
        return <String, dynamic>{
          'name': col.name,
          'color': _colorToString(col.color),
        };
      }).toList();

      await _firestore
          .collection('projects')
          .doc(_currentProjectId!)
          .collection('metadata')
          .doc('columns')
          .set(<String, dynamic>{
            'columns': columnsData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Silent failure, board can still work locally.
    }
  }

  /// Initializes default board columns when no custom configuration exists.
  void _initializeDefaultColumns() {
    _columns = <TaskColumn>[
      TaskColumn(name: 'Pendiente', color: Colors.grey),
      TaskColumn(name: 'En Progreso', color: Colors.blue),
      TaskColumn(name: 'En Revisión', color: Colors.orange),
      TaskColumn(name: 'Completado', color: Colors.green),
    ];
  }

  // ===== MAPPERS: PRIORITY & STATUS =====

  Priority _stringToPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'ALTA':
        return Priority.high;
      case 'LOW':
      case 'BAJA':
        return Priority.low;
      case 'MEDIUM':
      case 'MEDIA':
      default:
        return Priority.medium;
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'HIGH';
      case Priority.medium:
        return 'MEDIUM';
      case Priority.low:
        return 'LOW';
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

  // ===== COLOR HELPERS =====

  Color _parseColor(dynamic colorData) {
    if (colorData is int) {
      return Color(colorData);
    } else if (colorData is String) {
      final StringBuffer buffer = StringBuffer();
      buffer.write(colorData.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    return Colors.grey;
  }

  String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}

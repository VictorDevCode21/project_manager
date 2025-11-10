import 'package:flutter/material.dart';
import '../models/tasks_model.dart';

class TaskController extends ChangeNotifier {
  final List<TaskColumn> _columns = [
    TaskColumn(name: 'Pendiente', color: Colors.grey),
    TaskColumn(name: 'En Progreso', color: Colors.blue),
    TaskColumn(name: 'En Revisión', color: Colors.orange),
    TaskColumn(name: 'Completado', color: Colors.green),
  ];

  TaskController() {
    _loadColumns();
  }

  List<TaskColumn> get columns => _columns;

  Future<void> _loadColumns() async {}

  // Crear columna
  void addColumn(TaskColumn column) {
    _columns.add(column);
    notifyListeners();
  }

  // Eliminar columna
  void removeColumn(TaskColumn column) {
    _columns.remove(column);
    notifyListeners();
  }

  // Crear tarea dentro de una columna
  void addTaskToColumn(TaskColumn column, Task task) {
    final index = _columns.indexOf(column);
    if (index != -1) {
      _columns[index].tasks.add(task);
      notifyListeners();
    }
  }
}

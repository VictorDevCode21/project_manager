import 'package:flutter/material.dart';
import '../models/tasks_model.dart';

class TaskController extends ChangeNotifier {
  // Lista de columnas
  final List<TaskColumn> _columns = [
    TaskColumn(name: 'Pendiente', color: Colors.grey.shade200),
    TaskColumn(name: 'En Progreso', color: Colors.blue.shade100),
    TaskColumn(name: 'En Revisión', color: Colors.orange.shade100),
    TaskColumn(name: 'Completado', color: Colors.green.shade100),
  ];

  List<TaskColumn> get columns => _columns;

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

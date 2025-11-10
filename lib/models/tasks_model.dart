import 'dart:ffi';

class Color {}

class TaskColumn {
  final String name;
  final Color color;
  final List<Task> tasks;

  TaskColumn({required this.name, required this.color, this.tasks = const []});
}

class Task {
  final String title;
  final String description;
  final String projectType;
  final String assignee;
  final String priority;
  final String status;
  final Double estimatedHours;
  final DateTime dueTime;
  final String tags;

  Task({
    required this.title,
    required this.description,
    required this.projectType,
    required this.assignee,
    required this.priority,
    required this.status,
    required this.estimatedHours,
    required this.dueTime,
    required this.tags,
  });
}

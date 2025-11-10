import 'package:flutter/material.dart';

enum Priority { baja, media, alta }

enum Status { pendiente, enProgreso, enRevision, completado }

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
  final Priority priority;
  final Status status;
  final double estimatedHours;
  final DateTime? dueTime;
  final List<String> tags;

  Task({
    required this.title,
    required this.description,
    required this.projectType,
    required this.assignee,
    required this.priority,
    required this.status,
    required this.estimatedHours,
    this.dueTime,
    this.tags = const [],
  });
}

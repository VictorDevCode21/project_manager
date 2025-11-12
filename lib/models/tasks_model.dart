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
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String assignee;
  final Priority priority;
  final Status status;
  final double estimatedHours;
  final DateTime? dueTime;
  final List<String> tags;
  final String projectId;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.projectType,
    required this.assignee,
    required this.priority,
    required this.status,
    required this.estimatedHours,
    this.dueTime,
    this.tags = const [],
    required this.projectId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectType,
    String? assignee,
    Priority? priority,
    Status? status,
    double? estimatedHours,
    DateTime? dueTime,
    List<String>? tags,
    String? projectId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      dueTime: dueTime ?? this.dueTime,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
    );
  }
}

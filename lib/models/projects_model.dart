// lib/models/projects_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectPriority { low, medium, high }

enum ProjectStatus { planning, inProgress, completed, archived }

String priorityToString(ProjectPriority p) {
  // Firestore rules expect: 'LOW' | 'MEDIUM' | 'HIGH'
  switch (p) {
    case ProjectPriority.low:
      return 'LOW';
    case ProjectPriority.medium:
      return 'MEDIUM';
    case ProjectPriority.high:
      return 'HIGH';
  }
}

String statusToString(ProjectStatus s) {
  // Firestore rules expect: 'PLANNING' | 'IN_PROGRESS' | 'COMPLETED' | 'ARCHIVED'
  switch (s) {
    case ProjectStatus.planning:
      return 'PLANNING';
    case ProjectStatus.inProgress:
      return 'IN_PROGRESS';
    case ProjectStatus.completed:
      return 'COMPLETED';
    case ProjectStatus.archived:
      return 'ARCHIVED';
  }
}

class Project {
  final String id;
  final String ownerId;
  final String name;
  final String client;
  final String description;
  final String consultingType;
  final double budgetUsd;
  final ProjectPriority priority;
  final ProjectStatus status; // must exist and default to PLANNING
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.client,
    required this.description,
    required this.consultingType,
    required this.budgetUsd,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory used by your controller when creating a new project
  factory Project.newProject({
    required String id,
    required String ownerId,
    required String name,
    required String client,
    required String description,
    required String consultingType,
    required double budgetUsd,
    required ProjectPriority priority,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    return Project(
      id: id,
      ownerId: ownerId,
      name: name,
      client: client,
      description: description,
      consultingType: consultingType,
      budgetUsd: budgetUsd,
      priority: priority,
      status: ProjectStatus.planning, // default status required by rules
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    // IMPORTANT: enums serialized exactly as rules expect
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'client': client,
      'description': description,
      'consultingType': consultingType,
      'budgetUsd': budgetUsd,
      'priority': priorityToString(priority),
      'status': statusToString(status),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

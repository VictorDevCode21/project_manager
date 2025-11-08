// lib/models/projects_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wire enums used across app, rules and payloads.
enum ProjectPriority { low, medium, high }

enum ProjectStatus { planning, inProgress, completed, archived }

extension ProjectPriorityWire on ProjectPriority {
  String get wire => switch (this) {
    ProjectPriority.low => 'LOW',
    ProjectPriority.medium => 'MEDIUM',
    ProjectPriority.high => 'HIGH',
  };
  static ProjectPriority fromWire(String? v) {
    return switch (v) {
      'LOW' => ProjectPriority.low,
      'MEDIUM' => ProjectPriority.medium,
      'HIGH' => ProjectPriority.high,
      _ => ProjectPriority.medium, // safe default
    };
  }
}

extension ProjectStatusWire on ProjectStatus {
  String get wire => switch (this) {
    ProjectStatus.planning => 'PLANNING',
    ProjectStatus.inProgress => 'IN_PROGRESS',
    ProjectStatus.completed => 'COMPLETED',
    ProjectStatus.archived => 'ARCHIVED',
  };
  static ProjectStatus fromWire(String? v) {
    return switch (v) {
      'PLANNING' => ProjectStatus.planning,
      'IN_PROGRESS' => ProjectStatus.inProgress,
      'COMPLETED' => ProjectStatus.completed,
      'ARCHIVED' => ProjectStatus.archived,
      _ => ProjectStatus.planning, // safe default
    };
  }
}

class Project {
  final String id;
  final String ownerId;
  final String name;
  final String nameLower; // used for case-insensitive prefix search
  final String client;
  final String description;
  final String consultingType;
  final double budgetUsd;
  final ProjectPriority priority;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt; // server timestamp at creation

  Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.nameLower,
    required this.client,
    required this.description,
    required this.consultingType,
    required this.budgetUsd,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  /// Factory used by the controller when creating a new project.
  /// Status is not trusted here; controller/rules enforce PLANNING.
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
    return Project(
      id: id,
      ownerId: ownerId,
      name: name,
      nameLower: name.toLowerCase(),
      client: client,
      description: description,
      consultingType: consultingType,
      budgetUsd: budgetUsd,
      priority: priority,
      status: ProjectStatus.planning, // will be enforced to PLANNING anyway
      startDate: startDate,
      endDate: endDate,
      createdAt: null, // will be set by server FieldValue.serverTimestamp()
    );
  }

  /// Safe getters for nullable display
  double get budgetSafe => budgetUsd.isFinite ? budgetUsd : 0.0;
  String get clientSafe => client.isNotEmpty ? client : 'N/A';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'nameLower': nameLower,
      'client': client,
      'description': description,
      'consultingType': consultingType,
      'budgetUsd': budgetUsd,
      'priority': priority.wire,
      'status': status.wire,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      // createdAt is set in the controller with FieldValue.serverTimestamp()
    };
  }

  static Project fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final tsStart = d['startDate'] as Timestamp?;
    final tsEnd = d['endDate'] as Timestamp?;
    final tsCreated = d['createdAt'] as Timestamp?;

    return Project(
      id: d['id'] as String? ?? doc.id,
      ownerId: d['ownerId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      nameLower:
          (d['nameLower'] as String?) ??
          (d['name'] as String? ?? '').toLowerCase(),
      client: d['client'] as String? ?? '',
      description: d['description'] as String? ?? '',
      consultingType: d['consultingType'] as String? ?? '',
      budgetUsd: (d['budgetUsd'] is num)
          ? (d['budgetUsd'] as num).toDouble()
          : 0.0,
      priority: ProjectPriorityWire.fromWire(d['priority'] as String?),
      status: ProjectStatusWire.fromWire(d['status'] as String?),
      startDate: tsStart?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      endDate: tsEnd?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: tsCreated?.toDate(),
    );
  }
}

// lib/controllers/project_controller.dart
import 'dart:developer' as dev; // structured logging
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prolab_unimet/models/projects_model.dart';

/// Coordinates project persistence and queries. No UI here.
class ProjectController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProjectController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Creates a project owned by the current user.
  /// Default status is PLANNING (rules also enforce this).
  /// Adds search helpers: `nameLower` and `createdAt` (server timestamp).
  Future<String> createProject({
    required String name,
    required String client,
    required String description,
    required String consultingType,
    required double budgetUsd,
    required ProjectPriority priority,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    // 1) Normalize inputs
    final normalized = _normalizeInputs(
      name: name,
      client: client,
      description: description,
      consultingType: consultingType,
      budgetUsd: budgetUsd,
      startDate: startDate,
      endDate: endDate,
    );

    // 2) Validate inputs
    _validateInputs(
      name: normalized.name,
      client: normalized.client,
      description: normalized.description,
      consultingType: normalized.consultingType,
      budgetUsd: normalized.budgetUsd,
      startDate: normalized.startDate,
      endDate: normalized.endDate,
    );

    // 3) Prepare model and doc ref
    final projRef = _db.collection('projects').doc(); // auto-id
    final project = Project.newProject(
      id: projRef.id,
      ownerId: user.uid, // must match rules
      name: normalized.name,
      client: normalized.client,
      description: normalized.description,
      consultingType: normalized.consultingType,
      budgetUsd: normalized.budgetUsd,
      priority: priority,
      startDate: normalized.startDate,
      endDate: normalized.endDate,
      // IMPORTANT: Project model may already set status; we still hard-set in payload below
    );

    // 4) Log payload for debugging
    _logProjectPayload(stage: 'before_write', uid: user.uid, project: project);

    try {
      // 5) Build raw map to inject enforced/default fields
      final data = project.toMap()
        ..addAll({
          // Enforced by rules: must be PLANNING on create
          'status': 'PLANNING',
          // Lowercased name to support prefix search queries
          'nameLower': project.name.toLowerCase(),
          // Server timestamp for consistent ordering
          'createdAt': FieldValue.serverTimestamp(),
        });

      await projRef.set(data);

      _logInfo('project_created', {
        'projectId': projRef.id,
        'ownerId': user.uid,
      });

      return projRef.id;
    } on FirebaseException catch (e) {
      _logError('firestore_error', {
        'code': e.code,
        'message': e.message,
        'plugin': e.plugin,
      });

      // Friendlier messages for UI
      if (e.code == 'permission-denied') {
        throw Exception(
          '[permission-denied] You are not allowed to write this document. Check ownerId and Firestore rules.',
        );
      }
      if (e.code == 'failed-precondition') {
        throw Exception(
          '[failed-precondition] A rule condition was not met (status/priority/index?).',
        );
      }
      throw Exception('[${e.code}] ${e.message ?? 'Firestore error'}');
    } catch (e, st) {
      _logError('unexpected_error', {
        'error': e.toString(),
        'stack': st.toString(),
      });
      rethrow;
    }
  }

  // ---------------- Queries ----------------

  /// Wire values for status to avoid typos across app/rules.
  /// Keep in sync with security rules and any backend code.
  // enum ProjectStatus { planning, inProgress, completed, archived }

  // extension ProjectStatusX on ProjectStatus {
  //   String get wire {
  //     switch (this) {
  //       case ProjectStatus.planning:
  //         return 'PLANNING';
  //       case ProjectStatus.inProgress:
  //         return 'IN_PROGRESS';
  //       case ProjectStatus.completed:
  //         return 'COMPLETED';
  //       case ProjectStatus.archived:
  //         return 'ARCHIVED';
  //     }
  //   }
  // }

  /// Streams projects owned by the current user ordered by recency.
  /// Useful for simple lists without filters or search.
  Stream<List<Project>> streamOwnedProjects({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Project>>.empty();
    }
    return _db
        .collection('projects')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Project.fromDoc).toList());
  }

  /// Streams projects with optional filters (status, consultingType) and
  /// optional prefix search on project name (case-insensitive via `nameLower`).
  ///
  /// Indexes you will need (create them in console or firestore.indexes.json):
  /// - ownerId ASC, createdAt DESC
  /// - ownerId ASC, status ASC, createdAt DESC
  /// - ownerId ASC, consultingType ASC, createdAt DESC
  /// - ownerId ASC, status ASC, consultingType ASC, createdAt DESC
  /// - ownerId ASC, nameLower ASC
  /// - ownerId ASC, status ASC, nameLower ASC
  /// - ownerId ASC, consultingType ASC, nameLower ASC
  /// - ownerId ASC, status ASC, consultingType ASC, nameLower ASC
  Stream<QuerySnapshot<Map<String, dynamic>>> watchProjects({
    ProjectStatus? statusFilter,
    String? consultingTypeFilter,
    String? searchText,
    int limit = 50,
  }) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    Query<Map<String, dynamic>> q = _db
        .collection('projects')
        .where('ownerId', isEqualTo: uid);

    if (statusFilter != null) {
      q = q.where('status', isEqualTo: statusFilter.wire);
    }
    if (consultingTypeFilter != null &&
        consultingTypeFilter.trim().isNotEmpty &&
        consultingTypeFilter != 'Todos los tipos') {
      q = q.where('consultingType', isEqualTo: consultingTypeFilter.trim());
    }

    final s = searchText?.trim().toLowerCase();
    final hasSearch = s != null && s.isNotEmpty;

    if (hasSearch) {
      // Range queries require ordering by the same field
      q = q.orderBy('nameLower').startAt([s]).endAt(['$s\uf8ff']);
    } else {
      q = q.orderBy('createdAt', descending: true);
    }

    return q.limit(limit).snapshots();
  }

  // --------------- Helpers: validation, normalization, logging ---------------

  /// Normalizes text fields (trim) and returns a typed holder.
  _Normalized _normalizeInputs({
    required String name,
    required String client,
    required String description,
    required String consultingType,
    required double budgetUsd,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _Normalized(
      name: name.trim(),
      client: client.trim(),
      description: description.trim(),
      consultingType: consultingType.trim(),
      budgetUsd: budgetUsd,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Validates input. Throws ArgumentError with a clear message.
  void _validateInputs({
    required String name,
    required String client,
    required String description,
    required String consultingType,
    required double budgetUsd,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (name.isEmpty || name.length < 3) {
      throw ArgumentError('Project name must be at least 3 characters.');
    }
    if (client.isEmpty || client.length < 2) {
      throw ArgumentError('Client must be at least 2 characters.');
    }
    if (description.isEmpty || description.length < 10) {
      throw ArgumentError('Description must be at least 10 characters.');
    }
    if (consultingType.isEmpty || consultingType.length < 3) {
      throw ArgumentError('Consulting type must be at least 3 characters.');
    }

    if (budgetUsd.isNaN || budgetUsd.isInfinite || budgetUsd <= 0) {
      throw ArgumentError('Budget must be a valid positive number.');
    }
    if (budgetUsd > 1e9) {
      throw ArgumentError('Budget looks unrealistically large.');
    }

    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date.');
    }
    final minDate = DateTime(2000, 1, 1);
    final maxDate = DateTime.now().add(const Duration(days: 365 * 10));
    if (startDate.isBefore(minDate) || endDate.isAfter(maxDate)) {
      throw ArgumentError('Dates are out of the allowed range.');
    }
  }

  /// Logs a compact snapshot of the project to help debug payload issues.
  void _logProjectPayload({
    required String stage,
    required String uid,
    required Project project,
  }) {
    final data = {
      'stage': stage,
      'ownerId': uid,
      'id': project.id,
      'name': project.name,
      'client': project.client,
      'budgetUsd': project.budgetUsd,
      'priority': project.priority.toString(),
      'status': project.status.toString(),
      'startDate': project.startDate.toIso8601String(),
      'endDate': project.endDate.toIso8601String(),
      'consultingType': project.consultingType,
      'desc_len': project.description.length,
    };
    debugPrint('[ProjectController] payload: $data');
    dev.log('project_payload', name: 'ProjectController', error: data);
  }

  void _logInfo(String event, Map<String, Object?> data) {
    debugPrint('[ProjectController][$event] $data');
    dev.log(event, name: 'ProjectController', error: data);
  }

  void _logError(String event, Map<String, Object?> data) {
    debugPrint('[ProjectController][$event][ERROR] $data');
    dev.log(event, name: 'ProjectController', error: data);
  }
}

/// Internal normalized holder to keep code tidy.
class _Normalized {
  final String name;
  final String client;
  final String description;
  final String consultingType;
  final double budgetUsd;
  final DateTime startDate;
  final DateTime endDate;

  const _Normalized({
    required this.name,
    required this.client,
    required this.description,
    required this.consultingType,
    required this.budgetUsd,
    required this.startDate,
    required this.endDate,
  });
}

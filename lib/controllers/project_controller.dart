// lib/controllers/project_controller.dart
import 'dart:developer' as dev; // structured logging
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prolab_unimet/models/projects_model.dart';

/// Coordinates project persistence. No UI here.
class ProjectController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProjectController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Creates a project owned by the current user.
  /// No membership is created here (owner is not a member by default).
  /// Throws ArgumentError for invalid input and wraps FirebaseException with a readable message.
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

    // 3) Prepare model
    final projRef = _db.collection('projects').doc(); // auto-id
    final project = Project.newProject(
      id: projRef.id,
      ownerId: user
          .uid, // must match rules: request.resource.data.ownerId == request.auth.uid
      name: normalized.name,
      client: normalized.client,
      description: normalized.description,
      consultingType: normalized.consultingType,
      budgetUsd: normalized.budgetUsd,
      priority: priority,
      startDate: normalized.startDate,
      endDate: normalized.endDate,
    );

    // 4) Log payload for debugging
    _logProjectPayload(stage: 'before_write', uid: user.uid, project: project);

    try {
      // 5) Single write (no members set here)
      await projRef.set(project.toMap());

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

      // Mensajes más claros para la UI
      if (e.code == 'permission-denied') {
        throw Exception(
          '[permission-denied] No tienes permiso para leer/escribir ese recurso. Revisa el filtro (ownerId) y tus reglas.',
        );
      }
      if (e.code == 'failed-precondition') {
        throw Exception(
          '[failed-precondition] Alguna condición de las reglas no se cumple (priority/status?).',
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

  // ---------- Helpers: validation, normalization, logging ----------

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

  /// Validates input. Throws ArgumentError with a clear, actionable message.
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

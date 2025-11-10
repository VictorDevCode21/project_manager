// lib/controllers/project_controller.dart

import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/services/invite_service.dart';

class ProjectController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProjectController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // ===================== PROJECTS =====================

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

    final normalized = _normalizeInputs(
      name: name,
      client: client,
      description: description,
      consultingType: consultingType,
      budgetUsd: budgetUsd,
      startDate: startDate,
      endDate: endDate,
    );

    _validateInputs(
      name: normalized.name,
      client: normalized.client,
      description: normalized.description,
      consultingType: normalized.consultingType,
      budgetUsd: normalized.budgetUsd,
      startDate: normalized.startDate,
      endDate: normalized.endDate,
    );

    final projRef = _db.collection('projects').doc(); // auto-id
    final project = Project.newProject(
      id: projRef.id,
      ownerId: user.uid,
      name: normalized.name,
      client: normalized.client,
      description: normalized.description,
      consultingType: normalized.consultingType,
      budgetUsd: normalized.budgetUsd,
      priority: priority,
      startDate: normalized.startDate,
      endDate: normalized.endDate,
    );

    _logProjectPayload(stage: 'before_write', uid: user.uid, project: project);

    try {
      final data = project.toMap()
        ..addAll({
          'status': 'PLANNING', // validated by rules
          'nameLower': project.name.toLowerCase(),
          'visibleTo': project.visibleTo, // already includes [ownerId]
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
      if (e.code == 'permission-denied') {
        throw Exception(
          '[permission-denied] You are not allowed to write this document. Check ownerId, role claim and security rules.',
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

  /// Optional: server-side filtering for status, type, and prefix search.
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
      // Requires index on nameLower if combined with other where clauses.
      q = q.orderBy('nameLower').startAt([s]).endAt(['$s\uf8ff']);
    } else {
      q = q.orderBy('createdAt', descending: true);
    }

    return q.limit(limit).snapshots();
  }

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
      'visibleTo': project.visibleTo,
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

// ===================== MEMBERS =====================

extension ProjectMembersOps on ProjectController {
  /// Exposes current user's uid to views.
  ///
  String? get currentUserUid => _auth.currentUser?.uid;

  /// Streams the members of a given project.
  Stream<List<ProjectMember>> streamMembers(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('members')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProjectMember.fromDoc).toList());
  }

  /// Removes a member and updates visibleTo accordingly.
  Future<void> removeMember({
    required String projectId,
    required String memberUid,
  }) async {
    final projectRef = _db.collection('projects').doc(projectId);
    final memberRef = projectRef.collection('members').doc(memberUid);

    await _db.runTransaction((tx) async {
      final m = await tx.get(memberRef);
      if (m.exists) {
        tx.delete(memberRef);
      }
      tx.update(projectRef, {
        'visibleTo': FieldValue.arrayRemove([memberUid]),
      });
    });
  }
}

// ===================== INVITES =====================

extension ProjectInvitesOps on ProjectController {
  /// True if an Auth account already exists for the given email.
  Future<bool> _authAccountExists(String email) async {
    try {
      final methods = await (_auth as dynamic).fetchSignInMethodsForEmail(
        email.trim().toLowerCase(),
      );
      final list = methods as List<dynamic>?;
      return list != null && list.isNotEmpty;
    } catch (_) {
      // Fallback: do not block the flow if this capability is unavailable.
      return false;
    }
  }

  /// Joins base + path ensuring exactly one slash.
  String _joinBaseAndPath(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  /// Creates an invite in /projects/{projectId}/invites and sends the email
  /// through the Lambda Function. Chooses /login vs /register based on Auth.
  Future<void> createInviteAndSendEmail({
    required String projectId,
    required String recipientEmail,
  }) async {
    final inviter = _auth.currentUser;
    if (inviter == null) {
      throw Exception('No authenticated user.');
    }

    final email = recipientEmail.trim().toLowerCase();
    if (email.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    // Read public env vars directly
    final functionUrl = dotenv.env['FUNCTION_URL']?.trim() ?? '';
    final baseUrl = dotenv.env['INVITE_ACCEPT_BASE_URL']?.trim() ?? '';

    if (functionUrl.isEmpty) {
      throw Exception('FUNCTION_URL is missing in .env');
    }
    if (baseUrl.isEmpty) {
      throw Exception('INVITE_ACCEPT_BASE_URL is missing in .env');
    }

    // 1) Create invite doc with default status PENDING (no token used).
    final inviteRef = _db
        .collection('projects')
        .doc(projectId)
        .collection('invites')
        .doc();

    await inviteRef.set({
      'email': email,
      'status': 'PENDING', // PENDING | ACCEPTED | EXPIRED | CANCELLED
      'invitedBy': inviter.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
    });

    // 2) Decide path: /login if account exists, else /register
    final exists = await _authAccountExists(email);
    final path = exists ? '/login' : '/register';

    // 3) Build accept URL. We include pid so the frontend knows which project.
    final base = _joinBaseAndPath(baseUrl, path);
    final acceptUrl = Uri.parse(
      base,
    ).replace(queryParameters: {'pid': projectId}).toString();

    // 4) Send email via Lambda
    final mailer = InviteService();
    try {
      await mailer.sendInviteEmail(
        email: email,
        acceptUrl: acceptUrl,
        functionUrl: functionUrl,
      );
    } catch (e, _) {
      // Do not break UX if mailer fails; the invite exists and can be resent.
      _logError('mailer_failed', {'error': e.toString(), 'email': email});
      // If you prefer to surface the error to UI, uncomment the next line:
      // throw Exception('Invite created but mailer failed.');
    }
  }

  /// Streams invites for a project, filtered to PENDING only.
  /// If Firestore asks for a composite index (status+createdAt),
  /// create it or remove the orderBy if you want zero-index setup.
  Stream<List<ProjectInvite>> streamInvites(
    String projectId, {
    String status = 'PENDING',
  }) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('invites')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProjectInvite.fromDoc).toList());
  }

  /// Cancels an invite (rules define who is allowed).
  Future<void> cancelInvite(String projectId, String inviteId) async {
    final ref = _db
        .collection('projects')
        .doc(projectId)
        .collection('invites')
        .doc(inviteId);
    await ref.update({
      'status': 'CANCELLED',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': _auth.currentUser?.uid ?? '',
    });
  }
}

// ===================== LIGHTWEIGHT MODELS =====================

class ProjectMember {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime? addedAt;

  ProjectMember({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.addedAt,
  });

  factory ProjectMember.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ProjectMember(
      uid: d['uid'] ?? doc.id,
      email: (d['email'] ?? '').toString(),
      displayName: (d['displayName'] ?? '').toString(),
      role: (d['role'] ?? 'MEMBER').toString(),
      addedAt: (d['addedAt'] is Timestamp)
          ? (d['addedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class ProjectInvite {
  final String id;
  final String email;
  final String status;
  final DateTime? createdAt;

  ProjectInvite({
    required this.id,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  factory ProjectInvite.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ProjectInvite(
      id: doc.id,
      email: (d['email'] ?? '').toString(),
      status: (d['status'] ?? 'PENDING').toString(),
      createdAt: (d['createdAt'] is Timestamp)
          ? (d['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

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

      debugPrint('>>> [DEBUG] Auth UID: ${user.uid}');
      debugPrint('>>> [DEBUG] Payload ownerId: ${data['ownerId']}');

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
  /// Finds a user's UID by their emailLower field in /users.
  /// Returns UID string if found, null otherwise.
  /// Finds a user's UID by their email (exact string match).
  Future<String?> _findUidByEmail(String email) async {
    // Do not change case, only trim spaces
    final candidate = email.trim();

    try {
      debugPrint('[DEBUG] _findUidByEmail search: "$candidate"');

      final query = await _db
          .collection('users')
          .where('email', isEqualTo: candidate)
          .limit(1)
          .get();

      debugPrint(
        '[DEBUG] _findUidByEmail("$candidate") -> ${query.docs.length} docs',
      );

      if (query.docs.isEmpty) {
        debugPrint('[DEBUG] _findUidByEmail: no user found for "$candidate"');
        return null;
      }

      final uid = query.docs.first.id;
      debugPrint('[DEBUG] _findUidByEmail resolved uid: $uid');
      return uid;
    } catch (e) {
      _logError('find_user_by_email_failed', {
        'email': candidate,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Joins base + path ensuring exactly one slash.
  String _joinBaseAndPath(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  /// Creates an invite, sends an email, and handles both
  /// existing and non-existing users.
  /// - If user exists: creates an in-app notification.
  /// - If user does NOT exist: creates a 'pendingInvites' lookup doc.
  Future<void> createInviteAndSendEmail({
    required String projectId,
    required String projectName,
    required String recipientEmail,
  }) async {
    final inviter = _auth.currentUser;
    if (inviter == null) {
      throw Exception('No authenticated user.');
    }

    // Get inviter's name
    final inviterName =
        inviter.displayName ?? inviter.email ?? 'un administrador';

    final email = recipientEmail.trim();
    if (email.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    // 1) Check if user exists *before* doing anything else
    final recipientId = await _findUidByEmail(email);
    debugPrint(
      '[DEBUG] createInviteAndSendEmail recipientId: $recipientId for $email',
    );

    final WriteBatch batch = _db.batch();

    // 2) Create the "source of truth" invite doc in the batch
    final inviteRef = _db
        .collection('projects')
        .doc(projectId)
        .collection('invites')
        .doc(); // auto-id

    batch.set(inviteRef, {
      'email': email,
      'status': 'PENDING',
      'invitedBy': inviter.uid,
      'inviterName': inviterName,
      'projectName': projectName,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
      'recipientId': recipientId,
    });

    // 3) Handle existing vs non-existing user
    if (recipientId != null) {
      // User exists: create notification
      final notificationRef = _db.collection('notifications').doc();
      batch.set(notificationRef, {
        'recipientId': recipientId,
        'title': '¡Invitación al proyecto \'$projectName\'!',
        'body': 'Has sido invitado por $inviterName.',
        'type': 'project_invitation',
        'relatedId': projectId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'metadata': {
          'originalInvitePath': inviteRef.path,
          'originalInviteId': inviteRef.id,
        },
      });
    } else {
      // User does not exist: create pendingInvites lookup
      final pendingInviteRef = _db
          .collection('pendingInvites')
          .doc(inviteRef.id);

      batch.set(pendingInviteRef, {
        'email': email,
        'projectId': projectId,
        'projectName': projectName,
        'inviterName': inviterName,
        'originalInviteRef': inviteRef.path,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 4) Commit the batch
    try {
      await batch.commit();
    } catch (e) {
      _logError('invite_batch_failed', {'error': e.toString()});
      throw Exception('No se pudo crear la invitación. Intenta de nuevo.');
    }

    // 5) Send email via Lambda
    final functionUrl = dotenv.env['FUNCTION_URL']?.trim() ?? '';
    final baseUrl = dotenv.env['INVITE_ACCEPT_BASE_URL']?.trim() ?? '';

    if (functionUrl.isEmpty) {
      throw Exception('FUNCTION_URL is missing in .env');
    }
    if (baseUrl.isEmpty) {
      throw Exception('INVITE_ACCEPT_BASE_URL is missing in .env');
    }

    final exists = recipientId != null;
    final path = exists ? '/login' : '/register';

    final base = _joinBaseAndPath(baseUrl, path);
    final acceptUrl = Uri.parse(base)
        .replace(queryParameters: {'pid': projectId, 'inviteId': inviteRef.id})
        .toString();

    final mailer = InviteService();
    try {
      await mailer.sendInviteEmail(
        email: email,
        acceptUrl: acceptUrl,
        functionUrl: functionUrl,
      );
    } catch (e, _) {
      _logError('mailer_failed', {'error': e.toString(), 'email': email});
    }
  }

  /// Streams invites for a project, filtered to PENDING only.
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

    try {
      await ref.update({
        'status': 'CANCELLED',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': _auth.currentUser?.uid ?? 'unknown_user',
      });
    } on FirebaseException catch (e) {
      _logError('cancel_invite_failed', {
        'projectId': projectId,
        'inviteId': inviteId,
        'code': e.code,
        'message': e.message,
      });
      throw Exception(
        'Error al cancelar la invitación: ${e.message ?? e.code}',
      );
    } catch (e) {
      _logError('cancel_invite_failed_unknown', {
        'projectId': projectId,
        'inviteId': inviteId,
        'error': e.toString(),
      });
      throw Exception('Ocurrió un error inesperado al cancelar la invitación.');
    }
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

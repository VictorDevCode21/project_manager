import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prolab_unimet/models/projects_model.dart';

class ProjectController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProjectController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

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
          'status': 'PLANNING', // enforced by rules
          'nameLower': project.name.toLowerCase(),
          'visibleTo': project.visibleTo, // <- ya incluye [ownerId]
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
      'visibleTo': project.visibleTo, // <-- log útil para depurar reglas
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

extension ProjectMembersOps on ProjectController {
  /// Exposes the current user's uid to views when needed.
  String? get currentUserUid => _auth.currentUser?.uid;

  /// Streams the members of a given project.
  /// Data source: /projects/{projectId}/members
  Stream<List<ProjectMember>> streamMembers(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('members')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProjectMember.fromDoc).toList());
  }

  /// Invite a member by email:
  /// 1) Resolve /users doc by `email`
  /// 2) Upsert /projects/{id}/members/{uid}
  /// 3) arrayUnion(uid) into project's visibleTo
  Future<void> inviteMemberByEmail({
    required String projectId,
    required String inviterUid,
    required String email,
  }) async {
    final emailNorm = email.trim().toLowerCase();
    if (emailNorm.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    final usersCol = _db.collection('users');
    final q = await usersCol
        .where('email', isEqualTo: emailNorm)
        .limit(1)
        .get();
    if (q.docs.isEmpty) {
      throw StateError('User with that email was not found.');
    }

    final userDoc = q.docs.first;
    final uid = userDoc.id;
    final userData = userDoc.data();

    final projectRef = _db.collection('projects').doc(projectId);
    final memberRef = projectRef.collection('members').doc(uid);

    await _db.runTransaction((tx) async {
      final projSnap = await tx.get(projectRef);
      if (!projSnap.exists) {
        throw StateError('Project not found.');
      }

      tx.set(memberRef, {
        'uid': uid,
        'email': userData['email'] ?? '',
        'displayName': userData['displayName'] ?? '',
        'role': 'MEMBER',
        'invitedBy': inviterUid,
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.update(projectRef, {
        'visibleTo': FieldValue.arrayUnion([uid]),
      });
    });
  }

  /// Remove a member:
  /// 1) Delete /projects/{id}/members/{uid}
  /// 2) arrayRemove(uid) from visibleTo
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

/// Lightweight model used by the members stream (Model - MVC).
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

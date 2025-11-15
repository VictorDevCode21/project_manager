// lib/controllers/notification_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // <-- Needed for debugPrint
import 'package:prolab_unimet/models/notification_model.dart';

/// Controller for managing notification logic and data flow.
/// Handles all Firestore operations related to notifications.
class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _notificationsRef;
  late final CollectionReference _projectsRef;

  NotificationController() {
    _notificationsRef = _firestore.collection('notifications');
    _projectsRef = _firestore.collection('projects');
  }

  /// Returns a real-time stream of notifications for a specific user.
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs
              .map(
                (QueryDocumentSnapshot doc) =>
                    NotificationModel.fromFirestore(doc),
              )
              .toList();
        })
        .handleError((Object error) {
          debugPrint('Error fetching notifications: $error');
          return <NotificationModel>[];
        });
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update(<String, dynamic>{
        'isRead': true,
      });
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Deletes a specific notification from Firestore.
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  /// Handles the logic for accepting a project invitation.
  /// This is an atomic batch write that does 4 operations.
  /// Returns true on success, false on any failure.
  Future<bool> acceptProjectInvitation({
    required String notificationId,
    required String originalInvitePath,
    required String projectId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Update original invitation document
      final DocumentReference inviteDocRef = _firestore.doc(originalInvitePath);
      batch.update(inviteDocRef, <String, dynamic>{
        'status': 'ACCEPTED',
        'acceptedAt': FieldValue.serverTimestamp(),
        'recipientId': userId,
      });

      // 2. Add user to project members subcollection
      final DocumentReference memberDocRef = _projectsRef
          .doc(projectId)
          .collection('members')
          .doc(userId);

      batch.set(memberDocRef, <String, dynamic>{
        'uid': userId,
        'email': userEmail,
        'displayName': userName,
        'role': 'USER',
        'addedAt': FieldValue.serverTimestamp(),
      });

      // 3. Add userId to project.visibleTo
      final DocumentReference projectDocRef = _projectsRef.doc(projectId);
      batch.update(projectDocRef, <String, dynamic>{
        'visibleTo': FieldValue.arrayUnion(<String>[userId]),
      });

      // 4. Delete notification document
      final DocumentReference notificationDocRef = _notificationsRef.doc(
        notificationId,
      );
      batch.delete(notificationDocRef);

      await batch.commit();
      return true;
    } on FirebaseException catch (e, stack) {
      debugPrint(
        '[NotificationController][acceptProjectInvitation][FirebaseException] '
        '${e.code} - ${e.message}\n$stack',
      );
      return false;
    } catch (e, stack) {
      debugPrint(
        '[NotificationController][acceptProjectInvitation][Error] $e\n$stack',
      );
      return false;
    }
  }

  /// Handles the logic for declining a project invitation.
  /// Returns true on success, false on any failure.
  Future<bool> declineProjectInvitation({
    required String notificationId,
    required String projectId,
    required String userId,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Delete invitation inside project.invites (adjust doc id if needed)
      final DocumentReference inviteDocRef = _projectsRef
          .doc(projectId)
          .collection('invites')
          .doc(notificationId);
      batch.delete(inviteDocRef);

      // Delete notification
      final DocumentReference notificationDocRef = _notificationsRef.doc(
        notificationId,
      );
      batch.delete(notificationDocRef);

      await batch.commit();
      return true;
    } on FirebaseException catch (e, stack) {
      debugPrint(
        '[NotificationController][declineProjectInvitation][FirebaseException] '
        '${e.code} - ${e.message}\n$stack',
      );
      return false;
    } catch (e, stack) {
      debugPrint(
        '[NotificationController][declineProjectInvitation][Error] $e\n$stack',
      );
      return false;
    }
  }
}

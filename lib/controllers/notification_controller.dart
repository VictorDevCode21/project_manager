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
    debugPrint(
      '[NotificationController][declineProjectInvitation] START '
      'uid=$userId projectId=$projectId notificationId=$notificationId',
    );

    try {
      // 1) Load notification document
      final DocumentReference<Map<String, dynamic>> notificationDocRef =
          _notificationsRef.doc(notificationId)
              as DocumentReference<Map<String, dynamic>>;

      final DocumentSnapshot<Map<String, dynamic>> notifSnap =
          await notificationDocRef.get();

      if (!notifSnap.exists) {
        debugPrint(
          '[NotificationController][declineProjectInvitation] '
          'Notification not found, nothing to decline.',
        );
        return false;
      }

      final Map<String, dynamic> notifData = notifSnap.data()!;
      final dynamic notifRecipientId = notifData['recipientId'];
      final Map<String, dynamic> metadata =
          (notifData['metadata'] as Map<String, dynamic>?) ?? {};

      debugPrint(
        '[NotificationController][declineProjectInvitation] '
        'notif.recipientId=$notifRecipientId type=${notifData['type']} relatedId=${notifData['relatedId']}',
      );

      if (notifRecipientId != userId) {
        debugPrint(
          '[NotificationController][declineProjectInvitation] WARNING: '
          'userId ($userId) != notif.recipientId ($notifRecipientId). '
          'Delete may be blocked by security rules.',
        );
      }

      // 2) Resolve invite reference
      DocumentReference<Map<String, dynamic>>? inviteRef;

      final String? invitePath = metadata['originalInvitePath'] as String?;

      if (invitePath != null && invitePath.isNotEmpty) {
        // Use the original invite path from metadata
        inviteRef = _firestore.doc(invitePath);
        debugPrint(
          '[NotificationController][declineProjectInvitation] '
          'Using inviteRef from metadata: $invitePath',
        );
      } else {
        // Fallback: search in /projects/{projectId}/invites
        debugPrint(
          '[NotificationController][declineProjectInvitation] '
          'No originalInvitePath found, fallback query on invites...',
        );

        try {
          final QuerySnapshot<Map<String, dynamic>> query = await _projectsRef
              .doc(projectId)
              .collection('invites')
              .where('recipientId', isEqualTo: userId)
              .where('status', isEqualTo: 'PENDING')
              .limit(1)
              .get();

          debugPrint(
            '[NotificationController][declineProjectInvitation] '
            'fallback invites found=${query.docs.length}',
          );

          if (query.docs.isNotEmpty) {
            inviteRef = query.docs.first.reference;
          }
        } catch (e, st) {
          debugPrint(
            '[NotificationController][declineProjectInvitation] '
            'fallback invites query error: $e\n$st',
          );
        }
      }

      // 3) Build batch: update invite (if found) + delete notification
      final WriteBatch batch = _firestore.batch();

      if (inviteRef != null) {
        debugPrint(
          '[NotificationController][declineProjectInvitation] '
          'Adding invite update to batch: ${inviteRef.path}',
        );

        batch.update(inviteRef, {
          'status': 'DECLINED',
          'declinedAt': FieldValue.serverTimestamp(),
          'declinedBy': userId,
        });
      } else {
        debugPrint(
          '[NotificationController][declineProjectInvitation] '
          'No inviteRef resolved, skipping invite update.',
        );
      }

      debugPrint(
        '[NotificationController][declineProjectInvitation] '
        'Adding notification delete to batch: ${notificationDocRef.path}',
      );
      batch.delete(notificationDocRef);

      // 4) Commit batch
      await batch.commit();
      debugPrint(
        '[NotificationController][declineProjectInvitation] Batch commit OK.',
      );
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

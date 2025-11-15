// lib/controllers/notification_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prolab_unimet/models/notification_model.dart'; // Adjust path if needed

///
/// Controller for managing notification logic and data flow.
/// Handles all Firestore operations related to notifications.
///
class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the 'notifications' collection
  late final CollectionReference _notificationsRef;

  // Reference to the 'projects' collection (needed for invitation logic)
  late final CollectionReference _projectsRef;

  NotificationController() {
    _notificationsRef = _firestore.collection('notifications');
    _projectsRef = _firestore.collection('projects');
  }

  ///
  /// Gets a real-time stream of notifications for a specific user.
  ///
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsRef
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20) // Get the 20 most recent notifications
        .snapshots()
        .map((snapshot) {
          // Map the query snapshot to a list of AppNotification models
          return snapshot.docs.map((doc) {
            return NotificationModel.fromFirestore(doc);
          }).toList();
        })
        .handleError((error) {
          print("Error fetching notifications: $error");
          return [];
        });
  }

  ///
  /// Marks a specific notification as read.
  ///
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      print("Error marking as read: $e");
      // Optionally, throw a custom exception to be handled by the View
    }
  }

  ///
  /// Dismisses (deletes) a specific notification from Firestore.
  ///
  Future<void> dismissNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      print("Error dismissing notification: $e");
    }
  }

  // === 🚀 FUNCTION MODIFIED ===
  ///
  /// Handles the logic for accepting a project invitation.
  /// This is an atomic batch write that does 4 things.
  ///
  Future<void> acceptProjectInvitation({
    required String notificationId,
    required String
    originalInvitePath, // Passed from Provider (e.g. "projects/abc/invites/xyz")
    required String projectId, // Passed from Provider (e.g. "abc")
    required String userId,
    required String userName,
    required String userEmail, // Passed from Provider
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Update the *original invitation* doc
      // (This is allowed by 'isRecipientWrite()')
      final inviteDocRef = _firestore.doc(
        originalInvitePath,
      ); // Use the full path
      batch.update(inviteDocRef, {
        'status': 'ACCEPTED',
        'acceptedAt': FieldValue.serverTimestamp(),
        'recipientId': userId, // Ensure the UID is set
      });

      // 2. Add the user to the project's 'members' subcollection
      // (This is allowed by 'authed() && request.auth.uid == uid')
      final memberDocRef = _projectsRef
          .doc(projectId)
          .collection('members')
          .doc(userId);
      batch.set(memberDocRef, {
        'uid': userId,
        'email': userEmail,
        'displayName': userName,
        'role': 'USER', // Default role for new members
        'addedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update the main project doc to add user to 'visibleTo'
      // (This is allowed by 'isUser() && isOnlyAddingSelfToVisibleTo()')
      final projectDocRef = _projectsRef.doc(projectId);
      batch.update(projectDocRef, {
        'visibleTo': FieldValue.arrayUnion([userId]),
      });

      // 4. Delete the notification
      // (This is allowed by 'authed() && request.auth.uid == resource.data.recipientId')
      final notificationDocRef = _notificationsRef.doc(notificationId);
      batch.delete(notificationDocRef);

      // Commit all operations at once
      await batch.commit();
    } catch (e) {
      print("Error accepting invitation: $e");
      // The View should handle this error and inform the user
      throw Exception('Error al aceptar la invitación.');
    }
  }

  ///
  /// Handles the logic for declining a project invitation.
  /// This is an atomic batch write.
  ///
  Future<void> declineProjectInvitation({
    required String notificationId,
    required String projectId,
    required String userId,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // 1. Delete the invitation from the 'invitees' subcollection
      final inviteDocRef = _projectsRef
          .doc(projectId)
          .collection('invitees')
          .doc(userId);
      batch.delete(inviteDocRef);

      // 2. Delete the notification
      final notificationDocRef = _notificationsRef.doc(notificationId);
      batch.delete(notificationDocRef);

      // Commit all operations at once
      await batch.commit();
    } catch (e) {
      print("Error declining invitation: $e");
      throw Exception('Error al rechazar la invitación.');
    }
  }
}

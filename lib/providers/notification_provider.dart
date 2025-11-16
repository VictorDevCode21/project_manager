// lib/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/notification_controller.dart';
import 'package:prolab_unimet/models/notification_model.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';

/// ViewModel for notifications. Holds UI state and delegates logic
/// to NotificationController.
class NotificationProvider extends ChangeNotifier {
  // --- Dependencies ---
  final NotificationController _controller = NotificationController();

  AuthProvider? _authProvider;
  String? _currentUserId;

  // --- State ---
  List<NotificationModel> _notifications = <NotificationModel>[];
  bool _isLoading = false;
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;

  // --- Getters ---
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((NotificationModel n) => !n.isRead).length;

  NotificationModel? toastNotification;

  /// Called by ChangeNotifierProxyProvider whenever AuthProvider changes.
  void updateUser(AuthProvider authProvider) {
    final String? newUserId = authProvider.uid;

    if (newUserId == _currentUserId) {
      return;
    }

    _authProvider = authProvider;
    _currentUserId = newUserId;

    if (newUserId == null) {
      clearProvider();
    } else {
      listenToNotifications(newUserId);
    }
  }

  /// Subscribes to real-time notifications for the given user.
  void listenToNotifications(String userId) {
    _isLoading = true;
    notifyListeners();

    _notificationSubscription?.cancel();
    _notificationSubscription = _controller
        .getUserNotifications(userId)
        .listen(
          (List<NotificationModel> newNotifications) {
            _notifications = newNotifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Error in notification stream: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Clears state on logout.
  void clearProvider() {
    _notificationSubscription?.cancel();
    _notifications = <NotificationModel>[];
    _currentUserId = null;
    notifyListeners();
  }

  void clearToast() {
    toastNotification = null;
  }

  // ===================================================================
  // === Proxy methods: delegate single operations to the controller ===
  // ===================================================================

  Future<void> markAsRead(String notificationId) async {
    try {
      await _controller.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _controller.dismissNotification(notificationId);
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  /// Accepts a project invitation.
  /// Returns true on success, false on any error.
  Future<bool> acceptInvitation(NotificationModel notification) async {
    final AuthProvider? auth = _authProvider;

    if (auth == null || auth.uid == null || auth.email == null) {
      debugPrint(
        '[NotificationProvider][acceptInvitation] Missing auth data (uid/email).',
      );
      return false;
    }

    // Project id is stored in relatedId
    final String projectId = notification.relatedId;

    // Original invite path is stored in metadata["originalInvitePath"]
    final Map<String, dynamic>? metadata = notification.metadata;
    final String? originalInvitePath =
        metadata?['originalInvitePath'] as String?;

    if (projectId.isEmpty) {
      debugPrint(
        '[NotificationProvider][acceptInvitation] Invalid projectId (relatedId is empty).',
      );
      return false;
    }

    if (originalInvitePath == null || originalInvitePath.isEmpty) {
      debugPrint(
        '[NotificationProvider][acceptInvitation] Invalid originalInvitePath in metadata.',
      );
      return false;
    }

    try {
      final bool success = await _controller.acceptProjectInvitation(
        notificationId: notification.id,
        originalInvitePath: originalInvitePath,
        projectId: projectId,
        userId: auth.uid!,
        userName: auth.name ?? 'New member',
        userEmail: auth.email!,
      );

      return success;
    } catch (e, stack) {
      debugPrint('[NotificationProvider][acceptInvitation] Error: $e\n$stack');
      return false;
    }
  }

  /// Declines a project invitation.
  /// Returns true on success, false otherwise.
  Future<bool> declineInvitation(NotificationModel notification) async {
    final AuthProvider? auth = _authProvider;

    if (auth == null || auth.uid == null) {
      debugPrint(
        '[NotificationProvider][declineInvitation] Missing auth data (uid).',
      );
      return false;
    }

    try {
      final bool success = await _controller.declineProjectInvitation(
        notificationId: notification.id,
        projectId: notification.relatedId,
        userId: auth.uid!,
      );

      return success;
    } catch (e, stack) {
      debugPrint('[NotificationProvider][declineInvitation] Error: $e\n$stack');
      return false;
    }
  }
}

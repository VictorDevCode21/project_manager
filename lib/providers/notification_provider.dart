// lib/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/notification_controller.dart';
import 'package:prolab_unimet/models/notification_model.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';

///
/// This is the ViewModel in your MVC pattern.
/// It holds the state for the View (the UI) and
/// delegates all business logic to the NotificationController.
///
class NotificationProvider extends ChangeNotifier {
  // --- Dependencies ---
  final NotificationController _controller = NotificationController();

  // We no longer require AuthProvider in the constructor.
  // We store the auth provider and user ID locally.
  AuthProvider? _authProvider;
  String? _currentUserId; // Stores the current user's ID

  // --- State ---
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _notificationSubscription;

  // --- Getters (for the View) ---
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationModel? toastNotification;

  // NO CONSTRUCTOR IS NEEDED. The default `NotificationProvider()` is used.

  ///
  /// This is the 'update' method.
  /// It will be called by ChangeNotifierProxyProvider whenever AuthProvider changes.
  ///
  void updateUser(AuthProvider authProvider) {
    // Get the user ID from the new auth state
    final newUserId = authProvider.uid;

    // Check if the user has changed (e.g., logged in or out)
    if (newUserId == _currentUserId) {
      return; // No change, do nothing
    }

    _authProvider = authProvider; // Store the new auth provider
    _currentUserId = newUserId; // Store the new user ID

    if (newUserId == null) {
      // User logged out
      clearProvider();
    } else {
      // User logged in
      listenToNotifications(newUserId);
    }
  }

  ///
  /// Uses the Controller to fetch a real-time stream of notifications.
  ///
  void listenToNotifications(String userId) {
    _isLoading = true;
    notifyListeners();

    _notificationSubscription?.cancel();
    _notificationSubscription = _controller
        .getUserNotifications(userId)
        .listen(
          (newNotifications) {
            _notifications = newNotifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print("Error in notification stream: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  ///
  /// Clears the provider state, usually on logout.
  ///
  void clearProvider() {
    _notificationSubscription?.cancel();
    _notifications = [];
    _currentUserId = null; // Clear the user ID
    notifyListeners();
  }

  void clearToast() {
    toastNotification = null;
  }

  // ===================================================================
  // === 🚀 Proxy Methods: Connecting View to Controller ===
  // ===================================================================

  Future<void> markAsRead(String notificationId) async {
    try {
      await _controller.markAsRead(notificationId);
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _controller.dismissNotification(notificationId);
    } catch (e) {
      print("Error dismissing notification: $e");
    }
  }

  // === 🚀 FUNCTION MODIFIED ===
  Future<void> acceptInvitation(NotificationModel notification) async {
    final auth = _authProvider;
    if (auth == null || auth.uid == null || auth.email == null) {
      throw Exception('Usuario no autenticado o email no disponible.');
    }

    // --- 1. Extract data from the notification ---

    // The projectId is stored in relatedId
    final String? projectId = notification.relatedId;

    // The path to the *original invite* is in the metadata
    final metadata = notification.metadata;
    final String? originalInvitePath =
        metadata?['originalInvitePath'] as String?;

    // --- 2. Validate the data (This fixes the TypeError) ---
    if (projectId == null || projectId.isEmpty) {
      print("Error accepting invitation: projectId (relatedId) is null.");
      throw Exception("Error: ID de proyecto inválido en la notificación.");
    }

    if (originalInvitePath == null || originalInvitePath.isEmpty) {
      print(
        "Error accepting invitation: originalInvitePath is null in metadata.",
      );
      throw Exception("Error: Ruta de invitación inválida en la notificación.");
    }

    try {
      // --- 3. Pass ALL required data to the controller ---
      // We now pass both the path and the projectId,
      // plus the user's email which is needed for the members doc.
      await _controller.acceptProjectInvitation(
        notificationId: notification.id,
        originalInvitePath:
            originalInvitePath, // e.g., "projects/abc/invites/xyz"
        projectId: projectId, // e.g., "abc"
        userId: auth.uid!,
        userName: auth.name ?? 'Nuevo Miembro',
        userEmail: auth.email!, // Pass the user's email
      );

      print("Invitation accepted successfully."); // Good to have a success log
    } catch (e) {
      print("Error accepting invitation: $e");
      // Re-throw so the UI can show an error
      throw Exception('Error al aceptar la invitación.');
    }
  }

  Future<void> declineInvitation(NotificationModel notification) async {
    // Use the stored _authProvider
    final auth = _authProvider;
    if (auth == null || auth.uid == null) return; // Safety check

    try {
      await _controller.declineProjectInvitation(
        notificationId: notification.id,
        projectId: notification.relatedId,
        userId: auth.uid!, // Use the safe uid
      );
    } catch (e) {
      print("Error declining invitation: $e");
    }
  }
}

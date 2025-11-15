// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// A data model class for notifications.
///
class NotificationModel {
  final String id;
  final String recipientId; // The user this notification is for
  final String title;
  final String body;
  final String type; // e.g., 'project_invitation', 'task_assigned'
  final String relatedId; // e.g., the 'projectId' or 'taskId'
  final Timestamp createdAt;
  final bool isRead;

  // === 🚀 NEW FIELD ===
  /// Holds extra data, e.g., {'originalInvitePath': '...'}
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    required this.relatedId,
    required this.createdAt,
    this.isRead = false,
    this.metadata, // <-- 🚀 ADDED TO CONSTRUCTOR
  });

  ///
  /// Factory constructor to create a NotificationModel from a Firestore DocumentSnapshot.
  ///
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      title: data['title'] ?? 'Sin Título',
      body: data['body'] ?? 'Sin contenido',
      type:
          data['type'] ?? 'general', // Default to 'general' if type is missing
      relatedId: data['relatedId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,

      // === 🚀 ADDED METADATA PARSING ===
      // Safely cast the metadata field. It will be null if it doesn't exist
      // or isn't a Map.
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}

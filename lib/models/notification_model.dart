// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Timestamp createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? 'Sin Título',
      body: data['body'] ?? 'Sin contenido',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
// lib/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prolab_unimet/models/notification_model.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _uid;

  NotificationModel? _toastNotification;
  NotificationModel? get toastNotification => _toastNotification;

  void clearToast() {
    _toastNotification = null;
  }

  void listenToAuthChanges(AuthProvider auth) {
    if (auth.isAuthenticated && auth.userData?['uid'] != null) {
      final newUid = auth.userData!['uid'];
      if (_uid != newUid) {
        _uid = newUid;
        _listenToNotifications(_uid!);
      }
    } else {
      _subscription?.cancel();
      _notifications = [];
      _unreadCount = 0;
      _uid = null;
      notifyListeners();
    }
  }

  void _listenToNotifications(String uid) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {

      final newNotifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      if (newNotifications.isNotEmpty) {
        final latest = newNotifications.first;
        final bool isNew = !_notifications.any((n) => n.id == latest.id);

        if (isNew && !latest.isRead) {
          _toastNotification = latest;
        }
      }

      _notifications = newNotifications;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // ===== NUEVO MÉTODO PARA MARCAR INDIVIDUALMENTE =====
  Future<void> markAsRead(String notificationId) async {
    if (_uid == null) return;

    // Optimizamos la UI: actualizamos localmente el contador inmediatamente
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // Reemplazamos el modelo con una copia que tenga isRead=true
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        createdAt: _notifications[index].createdAt,
        isRead: true,
      );
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }

    // Actualizamos Firestore en segundo plano
    await _firestore
        .collection('users')
        .doc(_uid!)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
  // ===================================================

  Future<void> markAllAsRead() async {
    if (_uid == null || _unreadCount == 0) return;

    // Actualiza la UI de inmediato
    _unreadCount = 0;
    notifyListeners();

    final batch = _firestore.batch();
    final unread = _notifications.where((n) => !n.isRead);

    if (unread.isEmpty) return;

    for (var notification in unread) {
      final docRef = _firestore
          .collection('users')
          .doc(_uid!)
          .collection('notifications')
          .doc(notification.id);
      batch.update(docRef, {'isRead': true});
    }

    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
// lib/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;
  String? get token => _userData?['token'];
  String? get role => _userData?['role'];
  String? get name => _userData?['name'];
  String? get email => _userData?['email'];

  // === 🚀 NEW GETTER ===
  // Add this getter so other providers can safely access the user's ID
  String? get uid => _userData?['uid'];
  // === END OF NEW GETTER ===

  bool get isAuthenticated => _userData != null;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  String? _newLoginUserName;
  String? get newLoginUserName => _newLoginUserName;

  void clearNewLoginUser() {
    _newLoginUserName = null;
  }

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final token = await user.getIdToken();
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _userData = {
          // This data was already here, now we just have a getter for it
          'uid': user.uid,
          'email': user.email,
          'name': data['name'],
          'role': data['role'],
          'token': token,
        };
      }
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _userData = await _authService.loginUser(email: email, password: password);
    _newLoginUserName = _userData?['name'];
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    } finally {
      _userData = null;
      notifyListeners();
    }
  }
}

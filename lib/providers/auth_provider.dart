// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;
  String? get token => _userData?['token'];
  String? get role => _userData?['role'];
  String? get name => _userData?['name'];
  bool get isAuthenticated => _userData != null;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  /// Constructor that automatically restores session if a user is already logged in
  AuthProvider() {
    _initializeUser();
  }

  /// Restores user session using Firebase currentUser
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
          'uid': user.uid,
          'email': user.email,
          'name': data['name'],
          'role': data['role'],
          'token': token,
        };
      }
    }

    // Mark initialization as completed
    _isInitializing = false;
    notifyListeners();
  }

  /// Handles login using AuthService and stores session data
  Future<void> login(String email, String password) async {
    _userData = await _authService.loginUser(email: email, password: password);
    notifyListeners();
  }

  /// Handles logout and clears all stored user data
  Future<void> logout() async {
    await _authService.logout();
    _userData = null;
    notifyListeners();
  }
}

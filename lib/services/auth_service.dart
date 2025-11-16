// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Handles low level authentication logic with Firebase Auth and Firestore.
class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logs in a user with email and password, returning a normalized user map.
  ///
  /// On credential errors it rethrows [fb_auth.FirebaseAuthException] so that
  /// upper layers (LoginController) can inspect `code` and map messages.
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1) Authenticate user with Firebase Auth
      final fb_auth.UserCredential cred = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final fb_auth.User user = cred.user!;

      // 2) Retrieve user data from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Structural problem: user auth exists but profile does not.
        throw Exception('AUTH_USER_DOC_NOT_FOUND');
      }

      final Map<String, dynamic> data = userDoc.data()!;
      final String name = data['name'] ?? 'Sin nombre';
      final String role = data['role'] ?? 'Sin rol';

      // 3) Retrieve a fresh ID token (JWT)
      final String? token = await user.getIdToken();

      // 4) Return a structured map containing all useful info
      return <String, dynamic>{
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'role': role,
        'token': token,
      };
    } on fb_auth.FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      // Non-Firebase auth error (network, Firestore, etc.)
      throw Exception('AUTH_LOGIN_GENERIC_ERROR: $e');
    }
  }

  /// Registers a new user and creates its profile in Firestore.
  Future<fb_auth.User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    required DateTime birthDate,
    required String personId,
  }) async {
    try {
      // 1) Create user in Firebase Auth
      final fb_auth.UserCredential cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final String uid = cred.user!.uid;

      // 2) Save user data to Firestore
      await _firestore.collection('users').doc(uid).set(<String, dynamic>{
        'id': uid,
        'name': name,
        'email': email.trim(),
        'phone_number': phoneNumber,
        'role': role,
        'description': '',
        'personId': personId,
        'birth_date': birthDate.toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 3) Return the created user
      return cred.user;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Keep Spanish mapping here for registration flows
      throw Exception(_mapFirebaseErrorToSpanish(e));
    } catch (e) {
      throw Exception('Error desconocido: ${e.toString()}');
    }
  }

  /// Maps Firebase registration errors to Spanish messages.
  String _mapFirebaseErrorToSpanish(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'operation-not-allowed':
        return 'El registro con correo y contraseña no está habilitado.';
      default:
        return 'Ocurrió un error durante el registro. Intenta nuevamente.';
    }
  }

  /// Optional mapper kept in case you need it elsewhere (not used by login now).
  String _mapFirebaseLoginErrorToSpanish(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta registrada con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-email':
        return 'El correo ingresado no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      default:
        return 'Error al iniciar sesión. Intenta nuevamente.';
    }
  }

  /// Returns a fresh ID token for the current user, if any.
  Future<String?> getToken() async {
    final fb_auth.User? user = _auth.currentUser;
    return user != null ? user.getIdToken() : null;
  }

  /// Signs out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Exposes auth state changes stream.
  Stream<fb_auth.User?> get userChanges => _auth.authStateChanges();
}

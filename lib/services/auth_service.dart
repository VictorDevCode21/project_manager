import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === REGISTER USER ===
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    required DateTime birthDate,
  }) async {
    try {
      // 1️⃣ Create user in Firebase Auth
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;

      // 2️⃣ Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email.trim(),
        'phone_number': phoneNumber,
        'role': role,
        'birth_date': birthDate.toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Return the created user
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Use structured error handling instead of print
      throw Exception(_mapFirebaseErrorToSpanish(e));
    } catch (e) {
      // Catch any unexpected errors
      throw Exception('Error desconocido: ${e.toString()}');
    }
  }

  // === MAP FIREBASE ERROR TO USER-FRIENDLY MESSAGE ===
  String _mapFirebaseErrorToSpanish(FirebaseAuthException e) {
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

  // === GET USER TOKEN ===
  Future<String?> getToken() async {
    final user = _auth.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  // === SIGN OUT ===
  Future<void> logout() async {
    await _auth.signOut();
  }

  // === SESSION LISTENER ===
  Stream<User?> get userChanges => _auth.authStateChanges();
}

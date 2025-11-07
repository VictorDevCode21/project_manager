import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------
  // SCHEMA: users/{uid}
  // {
  //   id, name, email, role, phone, personId,
  //   birthDate (Timestamp),
  //   createdAt (serverTimestamp), updatedAt (serverTimestamp)
  // }
  // -------------------------

  // Helper: create or update Firestore profile idempotently
  Future<void> _ensureUserProfile({
    required String uid,
    required String email,
    String? name,
    String role = 'USER',
    String? phone,
    String? personId,
    DateTime? birthDate,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'email': email.toLowerCase(),
      'name': name ?? '',
      'role': role,
      'phone': phone ?? '',
      'personId': personId ?? '',
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge = idempotent
  }

  // === REGISTER USER ===
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    required DateTime birthDate,
    required String personId,
  }) async {
    try {
      // 1) Auth signup
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;

      // 2) Optional cosmetic update in Auth profile
      await user.updateDisplayName(name);

      // 3) Firestore profile (canonical, camelCase keys)
      await _ensureUserProfile(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        phone: phoneNumber,
        personId: personId,
        birthDate: birthDate,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseRegisterErrorEs(e));
    } on FirebaseException catch (e) {
      // Firestore/permission issues
      throw Exception(_mapFirestoreErrorEs(e));
    } catch (e) {
      throw Exception('Error desconocido en registro.');
    }
  }

  // === LOGIN USER ===
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1) Auth signIn
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = cred.user!;
      final uid = user.uid;

      // 2) Try to read profile
      final ref = _firestore.collection('users').doc(uid);
      var snap = await ref.get();

      // 3) Backfill profile if missing (legacy users)
      if (!snap.exists) {
        await _ensureUserProfile(
          uid: uid,
          email: user.email ?? email,
          name: user.displayName,
          role: 'USER',
        );
        snap = await ref.get(); // read again
      }

      final data = snap.data() ?? {};
      final name = (data['name'] as String?) ?? (user.displayName ?? '');
      final role = (data['role'] as String?) ?? 'USER';
      final freshToken = await user.getIdToken(true); // force refresh

      return {
        'uid': uid,
        'email': user.email,
        'name': name,
        'role': role,
        'token': freshToken,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseLoginErrorEs(e));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreErrorEs(e));
    } catch (_) {
      throw Exception('Error inesperado al iniciar sesión.');
    }
  }

  // === SIGN OUT ===
  Future<void> logout() async => _auth.signOut();

  // === TOKEN ===
  Future<String?> getToken() async {
    final user = _auth.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  // === ERROR MAPPING (Auth) ===
  String _mapFirebaseRegisterErrorEs(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'operation-not-allowed':
        return 'Método de registro deshabilitado.';
      default:
        return 'No se pudo registrar. (${e.code})';
    }
  }

  String _mapFirebaseLoginErrorEs(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta luego.';
      default:
        return 'No se pudo iniciar sesión. (${e.code})';
    }
  }

  // === ERROR MAPPING (Firestore) ===
  String _mapFirestoreErrorEs(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Acceso denegado en Firestore. Revisa reglas y dominios.';
    }
    if (e.code == 'unavailable') {
      return 'Servicio de base de datos no disponible temporalmente.';
    }
    return 'Error de base de datos: ${e.code}';
  }
}

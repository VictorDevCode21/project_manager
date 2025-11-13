// register_controller.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages user registration logic and form validation.
class RegisterController {
  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final personIdController = TextEditingController();

  // Services
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Extra state
  String? selectedRole;
  DateTime? selectedDate;

  // Form key
  final formKey = GlobalKey<FormState>();

  // ===== Validations =====
  // ... (All your validation functions are perfect, no changes needed)
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu nombre';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras y espacios';
    }
    return null;
  }

  String? validatePersonId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Por favor, ingresa tu cédula";
    }
    if (!RegExp(r'^\d{6,10}$').hasMatch(value)) {
      return "Cédula inválida (solo números, entre 6 y 10 dígitos)";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final regex = RegExp(
      r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(value.trim())) {
      return 'Solo se permiten correos institucionales de la UNIMET';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    final regex = RegExp(r'^0(424|412|414|416|422)\d{7}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Número inválido. Formato: 0(414|424|412|422|416 ) + 7 dígitos';
    }
    return null; // valid
  }

  String? strongPasswordValidator(
    String? value, {
    String? email,
    String? name,
    String? personId,
  }) {
    // ... (implementation unchanged)
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    final pwd = value;
    if (RegExp(r'\s').hasMatch(pwd)) {
      return 'La contraseña no debe contener espacios';
    }
    if (pwd.length < 10) {
      return 'Debe tener al menos 10 caracteres';
    }
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasLower = RegExp(r'[a-z]').hasMatch(pwd);
    final hasDigit = RegExp(r'\d').hasMatch(pwd);
    final hasSymbol = RegExp(r'[^\w]').hasMatch(pwd);
    if (!(hasUpper && hasLower && hasDigit && hasSymbol)) {
      return 'Debe incluir mayúsculas, minúsculas, números y símbolos';
    }
    if (RegExp(r'^(.)\1{5,}$').hasMatch(pwd)) {
      return 'Demasiado simple: caracteres repetidos';
    }
    String normalize(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final pwdNorm = normalize(pwd);
    if (email != null && email.isNotEmpty) {
      final emailUser = normalize(email.split('@').first);
      if (emailUser.isNotEmpty && pwdNorm.contains(emailUser)) {
        return 'No uses datos personales en la contraseña';
      }
    }
    if (name != null && name.isNotEmpty && pwdNorm.contains(normalize(name))) {
      return 'No uses tu nombre en la contraseña';
    }
    if (personId != null &&
        personId.isNotEmpty &&
        pwdNorm.contains(normalize(personId))) {
      return 'No uses tu cédula en la contraseña';
    }
    return null;
  }

  String? validatePassword(String? value) {
    return strongPasswordValidator(
      value,
      email: emailController.text,
      name: nameController.text,
      personId: personIdController.text,
    );
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Repite la contraseña';
    if (value != passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateRole() =>
      selectedRole == null ? 'Selecciona un tipo de usuario' : null;

  String? validateDate() {
    if (selectedDate == null) return 'Selecciona una fecha';
    if (selectedDate!.isAfter(DateTime.now())) {
      return 'Selecciona una fecha válida ';
    }
    return null;
  }

  bool get isFormCompletelyValid {
    final fieldsValid = formKey.currentState?.validate() ?? false;
    return fieldsValid && validateRole() == null && validateDate() == null;
  }

  void _normalizeInputs() {
    emailController.text = emailController.text.trim().toLowerCase();
    phoneController.text = phoneController.text.trim();
    passwordController.text = passwordController.text.trim();
    confirmPasswordController.text = confirmPasswordController.text.trim();
  }

  /// Registers the user. Returns true on success, false otherwise.
  Future<bool> registerUser(BuildContext context) async {
    // ... (Validation logic unchanged)
    final fieldsValid = formKey.currentState?.validate() ?? false;
    if (!fieldsValid || validateRole() != null || validateDate() != null) {
      return false;
    }
    formKey.currentState?.save();
    _normalizeInputs();

    final email = emailController.text;
    final name = nameController.text.trim();
    final personId = personIdController.text.trim();

    try {
      // 4. CALL AUTH SERVICE
      final User? user = await _authService.registerUser(
        name: name,
        email: email,
        password: passwordController.text,
        phoneNumber: phoneController.text,
        role: selectedRole ?? 'USER',
        birthDate: selectedDate!,
        personId: personId,
      );

      if (user != null) {
        // === 🚀 MODIFIED LOGIC START ===
        // Registration was successful. Now, check for pending invites
        // in the root /pendingInvites collection.
        // This is "fire-and-forget".
        _processPendingInvites(email, user.uid); // <-- Renamed function
        // === 🚀 MODIFIED LOGIC END ===

        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );
        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    }
  }

  // === 🚀 RENAMED AND MODIFIED FUNCTION ===
  /// Checks for pending invitations for the newly registered user
  /// by querying the /pendingInvites (root) collection.
  Future<void> _processPendingInvites(
    String newUserEmail,
    String newUserId,
  ) async {
    try {
      // 1. Find all invites in the ROOT /pendingInvites collection
      // This query is now allowed by our security rules.
      final invitesQuery = _db
          .collection('pendingInvites') // <-- CHANGED
          .where('email', isEqualTo: newUserEmail);

      final invitesSnapshot = await invitesQuery.get();

      if (invitesSnapshot.docs.isEmpty) {
        debugPrint("No pending invites found for $newUserEmail");
        return;
      }

      debugPrint(
        "Found ${invitesSnapshot.docs.length} pending invites for $newUserEmail",
      );

      // 2. We have invites. Prepare a batch write.
      final WriteBatch batch = _db.batch();

      for (final pendingDoc in invitesSnapshot.docs) {
        final inviteData = pendingDoc.data();

        // 3. Get info for the notification (from the de-normalized doc)
        final projectId =
            inviteData['projectId'] as String? ?? 'unknown_project';
        final projectName =
            inviteData['projectName'] as String? ?? 'un proyecto';
        final inviterName =
            inviteData['inviterName'] as String? ?? 'un administrador';
        final originalInvitePath = inviteData['originalInviteRef'] as String?;

        // 4. Create the new notification document
        // This is allowed by: (authed() && request.auth.uid == request.resource.data.recipientId)
        final notificationRef = _db.collection('notifications').doc();
        batch.set(notificationRef, {
          'recipientId': newUserId, // The new user
          'title': '¡Invitación al proyecto \'$projectName\'!',
          'body': 'Has sido invitado por $inviterName.',
          'type': 'project_invitation',
          'relatedId': projectId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          // NEW: Store metadata to link to the *real* invite
          // This will be used when the user clicks "Accept"
          'metadata': {
            'originalInvitePath': originalInvitePath,
            'pendingInviteId': pendingDoc.id,
          },
        });

        // 5. [CHANGED] We do NOT update the original invite.
        // We simply delete the "lookup" document from /pendingInvites.
        // This is allowed by the new rule: (authed() && token.email == resource.data.email)
        batch.delete(pendingDoc.reference);
      }

      // 6. Commit all changes to Firestore
      await batch.commit();
      debugPrint(
        "Successfully processed and deleted ${invitesSnapshot.docs.length} pending invites.",
      );
    } catch (e) {
      // Log error but don't block the user
      debugPrint("Error processing pending invites for $newUserId: $e");
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    personIdController.dispose();
  }
}

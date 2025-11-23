// lib/controllers/catalog_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prolab_unimet/models/consulting_types.dart';

/// Catalog queries only (no UI here).
class ConsultingTypeController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ConsultingTypeController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Streams the list of consulting type names for dropdowns.
  Stream<List<String>> streamConsultingTypeNames() {
    // Require session per your rules (read requires auth)
    if (_auth.currentUser == null) {
      return const Stream<List<String>>.empty();
    }
    return _db
        .collection('consulting_types')
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ConsultingType.fromMap(d.id, d.data()).name)
              .where((n) => n.isNotEmpty)
              .toList(),
        );
  }
}

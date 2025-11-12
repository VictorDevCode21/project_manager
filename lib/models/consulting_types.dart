// lib/models/consulting_type.dart
class ConsultingType {
  final String id;
  final String name;

  ConsultingType({required this.id, required this.name});

  factory ConsultingType.fromMap(String id, Map<String, dynamic>? data) {
    final d = data ?? const {};
    return ConsultingType(id: id, name: (d['name'] as String?)?.trim() ?? '');
  }
}

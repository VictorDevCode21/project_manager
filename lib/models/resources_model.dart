// resources_model.dart

abstract class ResourcesModel {
  final String id;
  final String name;
  final String state;
  final String lab;
  final String kind;
  final double hourlyTarif;

  ResourcesModel({
    required this.id,
    required this.name,
    required this.state,
    required this.lab,
    required this.kind,
    required this.hourlyTarif,
  });
}

class MaterialResource extends ResourcesModel {
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final String specs;
  final String condition;
  final List<String> projects;

  MaterialResource({
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.specs,
    required this.condition,
    required super.id,
    required super.name,
    required super.state,
    required this.projects,
    required super.lab,
    required super.kind,
    required super.hourlyTarif,
  });
}

class HumanResources extends ResourcesModel {
  final String review;
  final int usage;
  final int totalUsage;
  final String email;
  final String habilities;
  final String department;
  final List<String> projects;

  HumanResources({
    required this.review,
    required this.usage,
    required this.totalUsage,
    required this.email,
    required this.habilities,
    required this.department,
    required this.projects,
    required super.id,
    required super.name,
    required super.state,
    required super.lab,
    required super.kind,
    required super.hourlyTarif,
  });
}

class ResourceStats {
  final int availablePersonnel;
  final int totalPersonnel;
  final int availableEquipment;
  final int totalEquipment;
  final double averageUtilization;
  final int inMaintenance;

  ResourceStats({
    required this.availablePersonnel,
    required this.totalPersonnel,
    required this.availableEquipment,
    required this.totalEquipment,
    required this.averageUtilization,
    required this.inMaintenance,
  });
}

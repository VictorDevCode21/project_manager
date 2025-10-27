class ResourcesModel {
  late String name;
  late String state;
  late String lab;
  late String kind;
  late double hourlyTarif;
}

class MaterialResource extends ResourcesModel {
  late DateTime lastMaintenance;
  late DateTime nextMaintenance;
  late List<String> specs;
}

class HumanResources extends ResourcesModel {
  late String review;
  late int usage;
  late int totalUsage;
  late String email;
  late List<String> habilities;
  late String dapartment;
}

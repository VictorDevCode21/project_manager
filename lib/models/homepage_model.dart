// homepage_model.dart

class Project {
  final String title;
  final String client;
  final String category;
  final String status;
  final int progress;
  final String dueDate;

  Project({
    required this.title,
    required this.client,
    required this.category,
    required this.status,
    required this.progress,
    required this.dueDate,
  });
}

class HomePageModel {
  int activeProjects = 0;
  int expiringThisMonth = 0;
  int pendingTasks = 0;
  int dueSoon = 0;
  int resourceUtilization = 0;
  int generalProgress = 0;

  List<Project> recentProjects = [];

  HomePageModel({
    this.activeProjects = 0,
    this.expiringThisMonth = 0,
    this.pendingTasks = 0,
    this.dueSoon = 0,
    this.resourceUtilization = 0,
    this.generalProgress = 0,
  });
}

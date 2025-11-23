import 'package:prolab_unimet/models/projects_model.dart';

/// Holds summary data for the reports module.
class ReportsModel {
  final bool isLoading;
  final String? errorMessage;

  final int totalProjects;
  final int completedProjects;
  final int inProgressProjects;
  final int planningProjects;
  final double averageBudgetUsd;

  /// Cached list of projects to use in dropdowns and PDF generation.
  final List<Project> projects;

  const ReportsModel({
    this.isLoading = false,
    this.errorMessage,
    this.totalProjects = 0,
    this.completedProjects = 0,
    this.inProgressProjects = 0,
    this.planningProjects = 0,
    this.averageBudgetUsd = 0.0,
    this.projects = const [],
  });

  /// Creates a new instance with selected fields overridden.
  ReportsModel copyWith({
    bool? isLoading,
    String? errorMessage,
    int? totalProjects,
    int? completedProjects,
    int? inProgressProjects,
    int? planningProjects,
    double? averageBudgetUsd,
    List<Project>? projects,
  }) {
    return ReportsModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      inProgressProjects: inProgressProjects ?? this.inProgressProjects,
      planningProjects: planningProjects ?? this.planningProjects,
      averageBudgetUsd: averageBudgetUsd ?? this.averageBudgetUsd,
      projects: projects ?? this.projects,
    );
  }
}

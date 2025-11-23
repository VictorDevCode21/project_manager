import 'package:flutter/foundation.dart';

/// Lightweight project model used only by the dashboard.
class Project {
  final String id;
  final String title;
  final String client;
  final String category;
  final String status; // Human readable: "En progreso", "Completado", etc.
  final String dueDate; // Formatted, e.g. "12/11/2025" or "Sin fecha límite"
  final int progress; // 0 - 100

  const Project({
    required this.id,
    required this.title,
    required this.client,
    required this.category,
    required this.status,
    required this.dueDate,
    required this.progress,
  });
}

/// Immutable dashboard state model.
@immutable
class HomePageModel {
  final int activeProjects;
  final int pendingTasks;
  final int expiringThisMonth;
  final int dueSoon;
  final int resourceUtilization; // Placeholder for now
  final int generalProgress; // Average project progress 0-100
  final List<Project> recentProjects;

  const HomePageModel({
    required this.activeProjects,
    required this.pendingTasks,
    required this.expiringThisMonth,
    required this.dueSoon,
    required this.resourceUtilization,
    required this.generalProgress,
    required this.recentProjects,
  });

  factory HomePageModel.initial() {
    return const HomePageModel(
      activeProjects: 0,
      pendingTasks: 0,
      expiringThisMonth: 0,
      dueSoon: 0,
      resourceUtilization: 0,
      generalProgress: 0,
      recentProjects: <Project>[],
    );
  }

  HomePageModel copyWith({
    int? activeProjects,
    int? pendingTasks,
    int? expiringThisMonth,
    int? dueSoon,
    int? resourceUtilization,
    int? generalProgress,
    List<Project>? recentProjects,
  }) {
    return HomePageModel(
      activeProjects: activeProjects ?? this.activeProjects,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      expiringThisMonth: expiringThisMonth ?? this.expiringThisMonth,
      dueSoon: dueSoon ?? this.dueSoon,
      resourceUtilization: resourceUtilization ?? this.resourceUtilization,
      generalProgress: generalProgress ?? this.generalProgress,
      recentProjects: recentProjects ?? this.recentProjects,
    );
  }
}

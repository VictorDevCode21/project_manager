import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/homepage_model.dart';
import '../controllers/project_controller.dart';
import '../models/projects_model.dart' as domain;

// Dialogs already used in ProjectsView
import 'package:prolab_unimet/views/components/forms/create_project.dart';
import 'package:prolab_unimet/views/projects/project_details_dialog.dart';

class HomePageController extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ProjectController _projectController = ProjectController();

  HomePageModel _model = HomePageModel.initial();
  bool _isLoading = false;

  /// Cache for full domain projects to reuse in details dialog
  final Map<String, domain.Project> _projectCache = {};

  HomePageModel get model => _model;
  bool get isLoading => _isLoading;

  HomePageController({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = firebaseAuth ?? FirebaseAuth.instance {
    _loadDashboardData();
  }

  /// Public method to refresh dashboard manually if needed.
  Future<void> refresh() async {
    await _loadDashboardData();
  }

  /// Loads dashboard KPIs and recent projects based on current user.
  Future<void> _loadDashboardData() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      debugPrint('[HomePageController] No authenticated user found.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _projectCache.clear();

      final DateTime now = DateTime.now();
      final DateTime monthStart = DateTime(now.year, now.month, 1);
      final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);

      int activeProjects = 0;
      int expiringThisMonth = 0;
      int totalProgressSum = 0;
      int pendingTasks = 0;
      int dueSoonTasks = 0;

      final List<Project> recentProjects = [];

      // 1) Load owned/visible projects from ProjectController
      final List<domain.Project> ownedProjects = await _projectController
          .streamOwnedProjects()
          .first;

      for (final domain.Project p in ownedProjects) {
        _projectCache[p.id] = p;

        final String statusLabel = _mapStatusToLabel(p.status);
        final String title = p.name.isNotEmpty ? p.name : 'Proyecto sin título';
        final String client = p.client.isNotEmpty
            ? p.client
            : 'Cliente no definido';
        final String category = p.consultingType.isNotEmpty
            ? p.consultingType
            : 'Sin categoría';

        final DateTime? endDate = p.endDate;
        final String dueLabel = endDate != null
            ? '${endDate.day.toString().padLeft(2, '0')}/'
                  '${endDate.month.toString().padLeft(2, '0')}/'
                  '${endDate.year}'
            : 'Sin fecha límite';

        // 2) Load tasks from Firestore to compute progress and task KPIs
        final QuerySnapshot<Map<String, dynamic>> tasksSnapshot =
            await _firestore
                .collection('projects')
                .doc(p.id)
                .collection('tasks')
                .get();

        final int totalTasks = tasksSnapshot.docs.length;
        int completedTasks = 0;
        int projectPendingTasks = 0;
        int projectDueSoonTasks = 0;

        for (final taskDoc in tasksSnapshot.docs) {
          final Map<String, dynamic> tData = taskDoc.data();
          final String tStatus =
              (tData['status'] ?? 'PENDING') as String; // PENDING / COMPLETED

          DateTime? dueDate;
          if (tData['dueDate'] != null) {
            final dynamic rawDue = tData['dueDate'];
            if (rawDue is Timestamp) {
              dueDate = rawDue.toDate();
            } else if (rawDue is String) {
              dueDate = DateTime.tryParse(rawDue);
            }
          }

          final bool isCompleted = tStatus == 'COMPLETED';

          if (isCompleted) {
            completedTasks++;
          } else {
            projectPendingTasks++;
            if (dueDate != null &&
                dueDate.isAfter(now) &&
                dueDate.isBefore(now.add(const Duration(days: 7)))) {
              projectDueSoonTasks++;
            }
          }
        }

        final int projectProgress = totalTasks == 0
            ? 0
            : ((completedTasks / totalTasks) * 100).round();

        // 3) Build dashboard project
        recentProjects.add(
          Project(
            id: p.id,
            title: title,
            client: client,
            category: category,
            status: statusLabel,
            dueDate: dueLabel,
            progress: projectProgress,
          ),
        );

        // 4) KPIs
        if (p.status == domain.ProjectStatus.planning ||
            p.status == domain.ProjectStatus.inProgress) {
          activeProjects++;
        }

        if (endDate != null &&
            endDate.isAfter(monthStart) &&
            endDate.isBefore(nextMonthStart)) {
          expiringThisMonth++;
        }

        totalProgressSum += projectProgress;
        pendingTasks += projectPendingTasks;
        dueSoonTasks += projectDueSoonTasks;
      }

      final int generalProgress = recentProjects.isEmpty
          ? 0
          : (totalProgressSum / recentProjects.length).round();

      // Orden simple por fecha de entrega (si quieres por createdAt/updatedAt, ajustas aquí)
      recentProjects.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      final List<Project> limitedRecent = recentProjects.take(5).toList();

      _model = _model.copyWith(
        activeProjects: activeProjects,
        pendingTasks: pendingTasks,
        expiringThisMonth: expiringThisMonth,
        dueSoon: dueSoonTasks,
        resourceUtilization: 0, // Placeholder until resources module exists
        generalProgress: generalProgress,
        recentProjects: limitedRecent,
      );
    } catch (e) {
      debugPrint('[HomePageController] _loadDashboardData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Maps domain status enum to human readable Spanish label.
  String _mapStatusToLabel(domain.ProjectStatus status) {
    switch (status) {
      case domain.ProjectStatus.planning:
        return 'En planificación';
      case domain.ProjectStatus.inProgress:
        return 'En progreso';
      case domain.ProjectStatus.completed:
        return 'Completado';
      case domain.ProjectStatus.archived:
        return 'Archivado';
    }
  }

  // ===========================================================================
  // NAVIGATION / UI ACTIONS (USED BY DashboardView)
  // ===========================================================================

  void goToAllProjects(BuildContext context) {
    context.go('/admin-projects');
  }

  /// Uses the same modal flow as ProjectsView to create a new project.
  Future<void> goToCreateProject(BuildContext context) async {
    final NavigatorState nav = Navigator.of(context, rootNavigator: true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // 1) Open modal dialog to capture project data
    final ProjectCreateData? dto = await showDialog<ProjectCreateData>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const CreateProjectDialog(),
    );

    if (dto == null) return;
    if (!context.mounted) return;

    // 2) Show loading dialog while creating the project
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String projectId = await _projectController.createProject(
        name: dto.name,
        client: dto.client,
        description: dto.description,
        consultingType: dto.consultingType,
        budgetUsd: dto.budgetUsd,
        priority: dto.priority,
        startDate: dto.startDate,
        endDate: dto.endDate,
      );

      if (nav.canPop()) nav.pop(); // Close loading dialog

      messenger.showSnackBar(
        SnackBar(content: Text('Proyecto creado con id: $projectId')),
      );

      await refresh();
    } catch (e) {
      if (nav.canPop()) nav.pop(); // Close loading dialog
      messenger.showSnackBar(
        SnackBar(content: Text('Error al crear proyecto: $e')),
      );
    }
  }

  void goToAllTasks(BuildContext context) {
    context.go('/admin-tasks');
  }

  /// Placeholder: connect this to your real Task creation modal.
  Future<void> goToCreateTask(BuildContext context) async {
    // Aquí deberías abrir tu CreateTaskDialog o similar.
    // Por ahora dejo un snackbar para no inventar clases que no existen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El modal de creación de tareas aún no está conectado al dashboard.',
        ),
      ),
    );
  }

  void goToViewResources(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El módulo de recursos aún no está disponible.'),
      ),
    );
  }

  void goToAssignResources(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La asignación de recursos estará disponible próximamente.',
        ),
      ),
    );
  }

  void goToDashboard(BuildContext context) {
    // Ya estás en el dashboard; no es necesario hacer nada aquí por ahora.
  }

  void goToProjectProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La vista de progreso de proyectos aún está en desarrollo.',
        ),
      ),
    );
  }

  void goToReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El módulo de reportes y analytics aún no está disponible.',
        ),
      ),
    );
  }

  void goToGenerateReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La generación de reportes estará disponible próximamente.',
        ),
      ),
    );
  }

  /// Opens the project details dialog using the cached domain project.
  void goToProjectDetails(BuildContext context, String projectId) {
    final domain.Project? project = _projectCache[projectId];

    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró la información del proyecto.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (_) => ProjectDetailsDialog(project: project),
    );
  }
}

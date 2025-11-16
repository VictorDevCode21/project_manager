import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:prolab_unimet/models/tasks_model.dart' as tasks;
import 'package:prolab_unimet/views/tasks/add_task_dialog.dart';
import 'package:provider/provider.dart';

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

  /// Cache for full domain projects to reuse in details dialog.
  final Map<String, domain.Project> _projectCache = {};

  HomePageModel get model => _model;
  bool get isLoading => _isLoading;

  HomePageController({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = firebaseAuth ?? FirebaseAuth.instance {
    _loadDashboardData();
  }

  /// Public method to refresh dashboard data manually if needed.
  Future<void> refresh() async {
    await _loadDashboardData();
  }

  /// Loads dashboard KPIs and recent projects based on current user role.
  ///
  /// Role is resolved from Firebase Auth custom claims (`role`):
  /// - 'USER'         -> user scope (only projects in visibleTo and user tasks).
  /// - 'COORDINATOR'  -> coordinator scope (owner-based, full project/tasks).
  /// - 'ADMIN' / null -> same behavior as coordinator by default.
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

      final String role = await _getCurrentUserRole(user);

      if (role == 'USER') {
        await _loadDashboardForUser(user);
      } else {
        // Default branch for 'COORDINATOR', 'ADMIN' or any other value.
        await _loadDashboardForCoordinator(user);
      }
    } catch (e) {
      debugPrint('[HomePageController] _loadDashboardData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves the current user role from Firebase Auth token claims.
  ///
  /// This expects a custom claim named `role` with one of:
  /// 'ADMIN', 'COORDINATOR', 'USER'.
  /// If anything fails or the claim is missing, it falls back to 'USER'.
  Future<String> _getCurrentUserRole(User user) async {
    try {
      final IdTokenResult tokenResult = await user.getIdTokenResult(true);
      final Map<String, dynamic>? claims = tokenResult.claims;

      final dynamic rawRole = claims?['role'];
      if (rawRole is String && rawRole.isNotEmpty) {
        return rawRole;
      }
    } catch (e) {
      debugPrint('[HomePageController] _getCurrentUserRole error: $e');
    }
    return 'USER';
  }

  /// Loads dashboard data for a regular USER.
  ///
  /// Behavior:
  /// - Only counts projects where the user is in `visibleTo`.
  /// - Only counts ACTIVE projects (PLANNING / IN_PROGRESS) for KPIs.
  /// - Pending tasks and "due soon" tasks are calculated ONLY for tasks
  ///   whose `assignee` matches the current user (by uid or email).
  /// - Project progress is computed using ALL tasks in the project.
  Future<void> _loadDashboardForUser(User user) async {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);
    final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);

    int activeProjects = 0;
    int expiringThisMonth = 0;
    int totalProgressSum = 0;

    int pendingTasks = 0; // only tasks assigned to this user
    int dueSoonTasks = 0; // only tasks assigned to this user

    final List<Project> recentProjects = [];

    // 1) Query projects where the user is in `visibleTo`.
    final QuerySnapshot<Map<String, dynamic>> projectsSnap = await _firestore
        .collection('projects')
        .where('visibleTo', arrayContains: user.uid)
        .get();

    final List<domain.Project> visibleProjects = projectsSnap.docs
        .map(domain.Project.fromDoc)
        .toList();

    for (final domain.Project p in visibleProjects) {
      _projectCache[p.id] = p;

      final bool isActive =
          p.status == domain.ProjectStatus.planning ||
          p.status == domain.ProjectStatus.inProgress;

      // For USER role we only want active projects in KPIs.
      if (!isActive) {
        continue;
      }

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

      // 2) Load tasks for this project from Firestore.
      //    - Project progress uses all tasks.
      //    - User KPIs use only tasks assigned to this user.
      final QuerySnapshot<Map<String, dynamic>> tasksSnapshot = await _firestore
          .collection('projects')
          .doc(p.id)
          .collection('tasks')
          .get();

      final int totalTasks = tasksSnapshot.docs.length;
      int completedTasks = 0;

      int projectPendingTasksForUser = 0;
      int projectDueSoonTasksForUser = 0;

      final String uid = user.uid;
      final String? email = user.email;

      for (final taskDoc in tasksSnapshot.docs) {
        final Map<String, dynamic> tData = taskDoc.data();

        // Status mapping aligned with TaskController.
        final String rawStatus = (tData['status'] ?? 'pendiente')
            .toString()
            .toLowerCase();
        final bool isCompleted =
            rawStatus == 'completado' || rawStatus == 'completed';

        // Assignment detection aligned with TaskController:
        // we consider a task "mine" if `assignee` matches uid or email.
        final String assigneeRaw = (tData['assignee'] ?? '').toString().trim();

        bool isAssignedToUser = false;
        if (assigneeRaw.isNotEmpty) {
          if (assigneeRaw == uid || (email != null && assigneeRaw == email)) {
            isAssignedToUser = true;
          }
        }

        DateTime? dueDate;
        if (tData['dueDate'] != null) {
          final dynamic rawDue = tData['dueDate'];
          if (rawDue is Timestamp) {
            dueDate = rawDue.toDate();
          } else if (rawDue is String) {
            // TaskController stores dueDate as ISO string.
            dueDate = DateTime.tryParse(rawDue);
          }
        }

        // Progress: all tasks count.
        if (isCompleted) {
          completedTasks++;
        }

        // KPIs: only pending tasks assigned to current user.
        if (!isCompleted && isAssignedToUser) {
          projectPendingTasksForUser++;

          if (dueDate != null &&
              dueDate.isAfter(now) &&
              dueDate.isBefore(now.add(const Duration(days: 7)))) {
            projectDueSoonTasksForUser++;
          }
        }
      }

      final int projectProgress = totalTasks == 0
          ? 0
          : ((completedTasks / totalTasks) * 100).round();

      // 3) Build dashboard project item.
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

      // 4) Accumulate KPIs.
      activeProjects++;

      if (endDate != null &&
          endDate.isAfter(monthStart) &&
          endDate.isBefore(nextMonthStart)) {
        expiringThisMonth++;
      }

      totalProgressSum += projectProgress;
      pendingTasks += projectPendingTasksForUser;
      dueSoonTasks += projectDueSoonTasksForUser;
    }

    final int generalProgress = recentProjects.isEmpty
        ? 0
        : (totalProgressSum / recentProjects.length).round();

    // Sort by dueDate string (dd/mm/yyyy) as a simple approximation.
    recentProjects.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final List<Project> limitedRecent = recentProjects.take(5).toList();

    _model = _model.copyWith(
      activeProjects: activeProjects,
      pendingTasks: pendingTasks,
      expiringThisMonth: expiringThisMonth,
      dueSoon: dueSoonTasks,
      resourceUtilization: 0, // Placeholder until resources module exists.
      generalProgress: generalProgress,
      recentProjects: limitedRecent,
    );
  }

  /// Loads dashboard data for COORDINATOR/ADMIN-like roles.
  ///
  /// Behavior:
  /// - Uses `ProjectController.streamOwnedProjects()` to load projects
  ///   owned by the current user.
  /// - Counts ACTIVE projects (PLANNING / IN_PROGRESS) for KPIs.
  /// - Pending tasks and "due soon" tasks are calculated based on ALL tasks
  ///   in owned projects, not only tasks assigned to the coordinator.
  /// - Project progress is computed using all tasks in the project.
  Future<void> _loadDashboardForCoordinator(User user) async {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);
    final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);

    int activeProjects = 0;
    int expiringThisMonth = 0;
    int totalProgressSum = 0;
    int pendingTasks = 0;
    int dueSoonTasks = 0;

    final List<Project> recentProjects = [];

    // 1) Load owned projects from ProjectController.
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

      // 2) Load all tasks from Firestore for this project.
      final QuerySnapshot<Map<String, dynamic>> tasksSnapshot = await _firestore
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
        final String rawStatus = (tData['status'] ?? 'pendiente')
            .toString()
            .toLowerCase();

        final bool isCompleted =
            rawStatus == 'completed' || rawStatus == 'completado';

        DateTime? dueDate;
        if (tData['dueDate'] != null) {
          final dynamic rawDue = tData['dueDate'];
          if (rawDue is Timestamp) {
            dueDate = rawDue.toDate();
          } else if (rawDue is String) {
            dueDate = DateTime.tryParse(rawDue);
          }
        }

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

      // 3) Build dashboard project item.
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

      // 4) Accumulate KPIs.
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

    // Simple ordering by due date string.
    recentProjects.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final List<Project> limitedRecent = recentProjects.take(5).toList();

    _model = _model.copyWith(
      activeProjects: activeProjects,
      pendingTasks: pendingTasks,
      expiringThisMonth: expiringThisMonth,
      dueSoon: dueSoonTasks,
      resourceUtilization: 0, // Placeholder until resources module exists.
      generalProgress: generalProgress,
      recentProjects: limitedRecent,
    );
  }

  /// Maps domain status enum to a human readable Spanish label.
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

  /// Navigates to the main projects view.
  void goToAllProjects(BuildContext context) {
    context.go('/admin-projects');
  }

  /// Opens the "create project" dialog using the same flow as ProjectsView.
  Future<void> goToCreateProject(BuildContext context) async {
    final NavigatorState nav = Navigator.of(context, rootNavigator: true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // 1) Open modal dialog to capture project data.
    final ProjectCreateData? dto = await showDialog<ProjectCreateData>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const CreateProjectDialog(),
    );

    if (dto == null) return;
    if (!context.mounted) return;

    // 2) Show loading dialog while creating the project.
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

      if (nav.canPop()) nav.pop(); // Close loading dialog.

      messenger.showSnackBar(
        SnackBar(content: Text('Proyecto creado con id: $projectId')),
      );

      await refresh();
    } catch (e) {
      if (nav.canPop()) nav.pop(); // Close loading dialog.
      messenger.showSnackBar(
        SnackBar(content: Text('Error al crear proyecto: $e')),
      );
    }
  }

  /// Navigates to the main tasks view.
  void goToAllTasks(BuildContext context) {
    context.go('/admin-tasks');
  }

  /// Opens the AddTask dialog using the same flow as TaskView.
  Future<void> goToCreateTask(BuildContext context) async {
    final BuildContext scaffoldContext = context;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
      scaffoldContext,
    );

    TaskController taskController;

    try {
      taskController = Provider.of<TaskController>(
        scaffoldContext,
        listen: false,
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el controlador de tareas. Verifica el Provider en el árbol de widgets.',
          ),
        ),
      );
      return;
    }

    // Ensure there is at least one project to attach the task to.
    if (taskController.availableProjects.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No tienes proyectos disponibles para crear tareas.'),
        ),
      );
      return;
    }

    // Ensure a current project is selected.
    if (taskController.currentProjectId == null ||
        taskController.currentProjectId!.isEmpty) {
      final String firstProjectId =
          taskController.availableProjects.first['id'] as String;
      taskController.setCurrentProject(firstProjectId);
    }

    final String projectType =
        taskController.currentProjectData?['consultingType'] as String? ??
        'Proyecto';

    final String projectName =
        taskController.currentProjectData?['name'] as String? ?? 'Proyecto';

    if (!scaffoldContext.mounted) return;

    showDialog(
      context: scaffoldContext,
      builder: (BuildContext dialogContext) {
        return AddTask(
          columns: taskController.columns,
          projectId: taskController.currentProjectId!,
          projectType: projectType,
          projectName: projectName,
          projectMembers: taskController.projectMembers,
          onAddTask: (tasks.Task newTask) async {
            try {
              await taskController.addTask(newTask);
              if (scaffoldContext.mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Tarea "${newTask.title}" creada'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (scaffoldContext.mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Error creando tarea: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  /// Temporary stub for resources view navigation.
  void goToViewResources(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El módulo de recursos aún no está disponible.'),
      ),
    );
  }

  /// Temporary stub for resources assignment navigation.
  void goToAssignResources(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La asignación de recursos estará disponible próximamente.',
        ),
      ),
    );
  }

  /// Stub for dashboard navigation (already on dashboard).
  void goToDashboard(BuildContext context) {
    // No-op: this is already the dashboard.
  }

  /// Temporary stub for project progress view.
  void goToProjectProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La vista de progreso de proyectos aún está en desarrollo.',
        ),
      ),
    );
  }

  /// Temporary stub for reports view.
  void goToReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El módulo de reportes y analytics aún no está disponible.',
        ),
      ),
    );
  }

  /// Temporary stub for "generate report" action.
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

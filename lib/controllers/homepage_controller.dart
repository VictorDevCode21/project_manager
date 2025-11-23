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
  /// Role logic:
  /// - 'USER':
  ///   - Projects: only those where user.uid is in `visibleTo`.
  ///   - Pending tasks: only tasks where `assignee` is uid or email.
  ///   - Resource utilization: 0 (to avoid permission issues).
  ///
  /// - 'COORDINATOR':
  ///   - Projects: only those where `ownerId == uid`.
  ///   - Pending tasks: all non-completed tasks in owned projects.
  ///   - Resource utilization: based on human-resources + material-resources
  ///     that are assigned to any of the coordinator's projects.
  ///
  /// - 'ADMIN' (or anything else treated as admin):
  ///   - Projects: all projects.
  ///   - Pending tasks: all non-completed tasks in all projects.
  ///   - Resource utilization: global, using human-resources + material-resources.
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
      final String uid = user.uid;
      final String? email = user.email;

      final DateTime now = DateTime.now();
      final DateTime monthStart = DateTime(now.year, now.month, 1);
      final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);

      int activeProjects = 0;
      int expiringThisMonth = 0;
      int totalProgressSum = 0;
      int projectsCountForProgress = 0;

      int pendingTasks = 0;
      int dueSoonTasks = 0;

      final List<Project> recentProjects = [];

      // --------------------------------------------------------------------
      // 1) Select PROJECTS QUERY depending on role
      // --------------------------------------------------------------------
      QuerySnapshot<Map<String, dynamic>> projectsSnap;

      if (role == 'ADMIN') {
        // Admin sees all projects.
        projectsSnap = await _firestore.collection('projects').get();
      } else if (role == 'COORDINATOR') {
        // Coordinator sees only projects where he is the owner.
        projectsSnap = await _firestore
            .collection('projects')
            .where('ownerId', isEqualTo: uid)
            .get();
      } else {
        // USER: projects where uid is in visibleTo.
        projectsSnap = await _firestore
            .collection('projects')
            .where('visibleTo', arrayContains: uid)
            .get();
      }

      final List<domain.Project> projects = projectsSnap.docs
          .map(domain.Project.fromDoc)
          .toList();

      // --------------------------------------------------------------------
      // 2) Iterate projects and compute KPIs depending on role
      // --------------------------------------------------------------------
      for (final domain.Project p in projects) {
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

        // Load project tasks
        final QuerySnapshot<Map<String, dynamic>> tasksSnapshot =
            await _firestore
                .collection('projects')
                .doc(p.id)
                .collection('tasks')
                .get();

        final int totalTasks = tasksSnapshot.docs.length;
        int completedTasks = 0;

        // These counters are project-level but contribute to global KPIs.
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
          }

          // Decide if this task counts as "pending" and "due soon" in KPIs:
          // - USER: only tasks assigned to this user (uid or email).
          // - COORDINATOR / ADMIN: all tasks in the selected projects.
          bool shouldCountPendingForRole = false;

          if (!isCompleted) {
            if (role == 'USER') {
              final String assigneeRaw = (tData['assignee'] ?? '')
                  .toString()
                  .trim();

              if (assigneeRaw.isNotEmpty) {
                if (assigneeRaw == uid ||
                    (email != null && assigneeRaw == email)) {
                  shouldCountPendingForRole = true;
                }
              }
            } else {
              // Coordinator and Admin count all non-completed tasks.
              shouldCountPendingForRole = true;
            }
          }

          if (shouldCountPendingForRole) {
            projectPendingTasks++;

            if (dueDate != null &&
                dueDate.isAfter(now) &&
                dueDate.isBefore(now.add(const Duration(days: 7)))) {
              projectDueSoonTasks++;
            }
          }
        }

        // Compute project progress (based on all tasks)
        final int projectProgress = totalTasks == 0
            ? 0
            : ((completedTasks / totalTasks) * 100).round();

        // Build dashboard project item
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

        // Accumulate KPIs

        // Active projects (same rule for all roles).
        final bool isActive =
            p.status == domain.ProjectStatus.planning ||
            p.status == domain.ProjectStatus.inProgress;
        if (isActive) {
          activeProjects++;
        }

        if (endDate != null &&
            endDate.isAfter(monthStart) &&
            endDate.isBefore(nextMonthStart)) {
          expiringThisMonth++;
        }

        totalProgressSum += projectProgress;
        projectsCountForProgress++;

        pendingTasks += projectPendingTasks;
        dueSoonTasks += projectDueSoonTasks;
      }

      final int generalProgress = projectsCountForProgress == 0
          ? 0
          : (totalProgressSum / projectsCountForProgress).round();

      // Sort recent projects by due date string (approximate ordering).
      recentProjects.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      final List<Project> limitedRecent = recentProjects.take(5).toList();

      // --------------------------------------------------------------------
      // 3) Resource Utilization depending on role
      // --------------------------------------------------------------------
      int resourceUtilization = 0;
      if (role == 'ADMIN' || role == 'COORDINATOR') {
        final double utilization = await _calculateResourceUtilization(
          role,
          projects,
        );
        resourceUtilization = utilization.round();
      }

      _model = _model.copyWith(
        activeProjects: activeProjects,
        pendingTasks: pendingTasks,
        expiringThisMonth: expiringThisMonth,
        dueSoon: dueSoonTasks,
        resourceUtilization: resourceUtilization,
        generalProgress: generalProgress,
        recentProjects: limitedRecent,
      );
    } catch (e) {
      debugPrint('[HomePageController] _loadDashboardData error: $e');
    }
  }

  /// Resolves the current user role using:
  /// 1) Custom claims: user.getIdTokenResult()
  /// 2) Fallback: /users/{uid}.role
  /// If everything fails, defaults to 'USER'.
  Future<String> _getCurrentUserRole(User user) async {
    String resolvedRole = 'USER';

    try {
      final IdTokenResult tokenResult = await user.getIdTokenResult(true);
      final Map<String, dynamic>? claims = tokenResult.claims;

      final dynamic rawRole = claims?['role'];
      if (rawRole is String && rawRole.isNotEmpty) {
        resolvedRole = rawRole;
      } else {
        final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        final Map<String, dynamic>? data = userDoc.data();
        final dynamic docRole = data?['role'];

        if (docRole is String && docRole.isNotEmpty) {
          resolvedRole = docRole;
        }
      }
    } catch (e) {
      debugPrint('[HomePageController] _getCurrentUserRole error: $e');
    }

    debugPrint('[HomePageController] Resolved role: $resolvedRole');
    return resolvedRole;
  }

  /// Calculates resource utilization.
  ///
  /// For ADMIN:
  ///   - Considers all resources that are assigned to any project
  ///     (i.e. `projects` array contains something different from "No hay proyectos").
  ///
  /// For COORDINATOR:
  ///   - Considers only resources whose `projects` array references at least
  ///     one of the coordinator's projects (matching by id OR by project name).
  ///
  /// Human resources:
  ///   - If `totalUsage` and `use` exist, ratio = use / totalUsage (clamped).
  ///   - Otherwise falls back to binary counting (1 if assigned, 0 if not).
  ///
  /// Material resources:
  ///   - Binary counting: 1 if assigned to any relevant project, 0 otherwise.
  Future<double> _calculateResourceUtilization(
    String role,
    List<domain.Project> projects,
  ) async {
    double used = 0;
    double total = 0;

    // Prepare sets for quick matching in COORDINATOR mode
    final Set<String> projectIds = projects
        .map((p) => p.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    final Set<String> projectNames = projects
        .map((p) => p.name)
        .where((name) => name.isNotEmpty)
        .toSet();

    try {
      // ===========================
      // Human resources
      // ===========================
      final QuerySnapshot<Map<String, dynamic>> hrSnap = await _firestore
          .collection('human-resources')
          .get();

      for (final doc in hrSnap.docs) {
        final Map<String, dynamic> data = doc.data();

        final List<dynamic> rawProjects =
            (data['projects'] as List<dynamic>?) ?? const [];
        final List<String> resourceProjects = rawProjects
            .map((e) => e.toString())
            .toList();

        bool isAssignedRelevant = false;

        if (role == 'ADMIN') {
          // Admin: resource is "assigned" if it has any project different from "No hay proyectos"
          isAssignedRelevant = resourceProjects.any(
            (p) => p.trim().toLowerCase() != 'no hay proyectos',
          );
        } else {
          // COORDINATOR: resource counts only if it is linked to one of his projects
          isAssignedRelevant = resourceProjects.any((p) {
            final String value = p.toString();
            return projectIds.contains(value) || projectNames.contains(value);
          });
        }

        // Try to use totalUsage/use if present
        final double totalUsage =
            (data['totalUsage'] as num?)?.toDouble() ?? 0.0;
        final double usedUsage = (data['use'] as num?)?.toDouble() ?? 0.0;

        if (totalUsage > 0) {
          total += totalUsage;
          if (isAssignedRelevant) {
            // Clamp to avoid weird values
            final double clampedUsed = usedUsage
                .clamp(0.0, totalUsage)
                .toDouble();
            used += clampedUsed;
          }
        } else {
          // Fallback binary counting
          total += 1;
          if (isAssignedRelevant) {
            used += 1;
          }
        }
      }

      // ===========================
      // Material resources
      // ===========================
      final QuerySnapshot<Map<String, dynamic>> mrSnap = await _firestore
          .collection('material-resources')
          .get();

      for (final doc in mrSnap.docs) {
        final Map<String, dynamic> data = doc.data();

        final List<dynamic> rawProjects =
            (data['projects'] as List<dynamic>?) ?? const [];
        final List<String> resourceProjects = rawProjects
            .map((e) => e.toString())
            .toList();

        bool isAssignedRelevant = false;

        if (role == 'ADMIN') {
          isAssignedRelevant = resourceProjects.any(
            (p) => p.trim().toLowerCase() != 'no hay proyectos',
          );
        } else {
          isAssignedRelevant = resourceProjects.any((p) {
            final String value = p.toString();
            return projectIds.contains(value) || projectNames.contains(value);
          });
        }

        // For materials we treat each doc as one unit
        total += 1;
        if (isAssignedRelevant) {
          used += 1;
        }
      }
    } catch (e) {
      debugPrint(
        '[HomePageController] _calculateResourceUtilization error: $e',
      );
    }

    if (total <= 0) {
      return 0;
    }
    return (used / total) * 100.0;
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

    final ProjectCreateData? dto = await showDialog<ProjectCreateData>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const CreateProjectDialog(),
    );

    if (dto == null) return;
    if (!context.mounted) return;

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

      if (nav.canPop()) nav.pop();

      messenger.showSnackBar(
        SnackBar(content: Text('Proyecto creado con id: $projectId')),
      );

      await refresh();
    } catch (e) {
      if (nav.canPop()) nav.pop();
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

    if (taskController.availableProjects.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No tienes proyectos disponibles para crear tareas.'),
        ),
      );
      return;
    }

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

  void goToDashboard(BuildContext context) {
    // No-op: already on dashboard.
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

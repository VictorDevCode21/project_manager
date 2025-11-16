import 'package:flutter/material.dart';
import '../models/homepage_model.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/controllers/resources_controller.dart';

class HomePageController extends ChangeNotifier {
  final HomePageModel _model = HomePageModel();
  final ResourcesController _resourcesController = ResourcesController();
  HomePageModel get model => _model;

  HomePageController() {
    _fetchInitialData();
    _subscribeToResourceStats();
  }
  void _subscribeToResourceStats() {
    _resourcesController.fetchAndCalculateStats();

    _resourcesController.statsNotifier.addListener(_updateResourceUtilization);
  }

  void _updateResourceUtilization() {
    final utilization =
        _resourcesController.statsNotifier.value.averageUtilization;

    _model.resourceUtilization = (utilization * 100).toInt();

    notifyListeners();
  }

  @override
  void dispose() {
    _resourcesController.statsNotifier.removeListener(
      _updateResourceUtilization,
    );
    _resourcesController.dispose();
    super.dispose();
  }

  void _fetchInitialData() {
    _model.activeProjects = 12;
    _model.expiringThisMonth = 2;
    _model.pendingTasks = 47;
    _model.dueSoon = 15;

    _model.generalProgress = 73;
    _model.recentProjects = [
      Project(
        title: 'Análisis de Calidad del Agua',
        client: 'Empresa ABC',
        category: 'Calidad Ambiental',
        status: 'En Progreso',
        progress: 65,
        dueDate: '15 Dic, 2024',
      ),
      Project(
        title: 'Inspección de Obra Civil',
        client: 'Proyecto XYZ',
        category: 'Construcción',
        status: 'Planificación',
        progress: 25,
        dueDate: '20 Ene, 2025',
      ),
      Project(
        title: 'Análisis de Lubricantes Industriales',
        client: '',
        category: 'Lubricantes',
        status: 'Completado',
        progress: 100,
        dueDate: '30 Nov, 2024',
      ),
    ];
    notifyListeners();
  }

  void goToAllProjects(BuildContext context) {
    context.go('/admin-projects');
  }

  void goToCreateProject(BuildContext context) {
    //context.go('/admin-projects/create');
  }
  void goToProjectDetails(BuildContext context, String projectId) {
    //context.go('/admin-projects/$projectId');
  }

  void goToAllTasks(BuildContext context) {
    //context.go('/admin-tasks');
  }

  void goToCreateTask(BuildContext context) {
    //context.go('/admin-tasks/create');
  }

  void goToViewResources(BuildContext context) {
    context.go('/admin-resources');
  }

  void goToAssignResources(BuildContext context) {
    context.go('/admin-resources/assign');
  }

  void goToDashboard(BuildContext context) {
    context.go('/admin-dashboard');
  }

  void goToProjectProgress(BuildContext context) {
    context.go('/admin-projects');
  }

  void goToReports(BuildContext context) {
    //context.go('/admin-reports');
  }

  void goToGenerateReport(BuildContext context) {
    //context.go('/admin-reports/generate');
  }
}

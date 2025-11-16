// lib/models/dashboard_model.dart

/// Clase para representar las métricas principales del dashboard.
class MetricCard {
  final String title;
  final String value;
  final String change;
  final bool isPositiveChange;
  final String? subtitle;

  MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositiveChange,
    this.subtitle,
  });
}

/// Clase para representar la distribución por tipo (Gráfico de pastel).
class ProjectDistribution {
  final String type;
  final double percentage;
  final double value;
  ProjectDistribution({
    required this.type,
    required this.percentage,
    required this.value,
  });
}

/// Clase para representar el progreso mensual (Gráfico de área apilada).
class MonthlyProgress {
  final String month;
  final double completed;
  final double inProgress;
  final double planned;

  MonthlyProgress({
    required this.month,
    required this.completed,
    required this.inProgress,
    required this.planned,
  });
}

/// Clase principal que contiene todos los datos del dashboard.
class DashboardModel {
  final List<MetricCard> metricCards;
  final List<ProjectDistribution> distributionData;
  final List<MonthlyProgress> progressData;

  DashboardModel({
    required this.metricCards,
    required this.distributionData,
    required this.progressData,
  });

  /// Método estático para cargar datos de muestra (Simula la carga de una API).
  static DashboardModel loadSampleData() {
    return DashboardModel(
      metricCards: [
        MetricCard(
          title: 'Proyectos Activos',
          value: '12',
          change: '+6.7%',
          isPositiveChange: true,
        ),
        MetricCard(
          title: 'Tareas Completadas',
          value: '47',
          change: '+2.3%',
          isPositiveChange: true,
        ),
        MetricCard(
          title: 'Utilización de Recursos',
          value: '85%',
          change: '~5%',
          isPositiveChange: false,
        ),
        MetricCard(
          title: 'Problemas Críticos',
          value: '3',
          change: 'Atención',
          isPositiveChange: false,
          subtitle: 'Atención',
        ),
      ],
      distributionData: [
        ProjectDistribution(
          type: 'Calidad Ambiental',
          percentage: 0.35,
          value: 35,
        ),
        ProjectDistribution(type: 'Combustibles', percentage: 0.20, value: 20),
        ProjectDistribution(type: 'Lubricantes', percentage: 0.20, value: 20),
        ProjectDistribution(type: 'Construcción', percentage: 0.25, value: 25),
      ],
      progressData: [
        MonthlyProgress(month: 'Jul', completed: 2, inProgress: 4, planned: 8),
        MonthlyProgress(month: 'Ago', completed: 3, inProgress: 5, planned: 6),
        MonthlyProgress(month: 'Sep', completed: 5, inProgress: 6, planned: 5),
        MonthlyProgress(month: 'Oct', completed: 7, inProgress: 7, planned: 4),
        MonthlyProgress(month: 'Nov', completed: 8, inProgress: 6, planned: 3),
        MonthlyProgress(month: 'Dic', completed: 9, inProgress: 5, planned: 2),
      ],
    );
  }
}

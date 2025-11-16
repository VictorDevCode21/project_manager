// lib/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa el controlador y carga los datos.
    // Usamos ChangeNotifierProvider para que la vista se actualice
    // automáticamente cuando el controlador cambie (notifyListeners).
    return ChangeNotifierProvider(
      create: (_) => DashboardController()..loadDashboardData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard de Proyectos'),
          centerTitle: false,
          actions: const [_TimeRangeSelector(), _ExportButton()],
        ),
        body: Consumer<DashboardController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }

            if (controller.dashboardData == null) {
              return const Center(child: Text('No hay datos disponibles.'));
            }

            final data = controller.dashboardData!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sección de Métricas Principales ---
                  _MetricsGrid(metrics: data.metricCards),

                  const SizedBox(height: 24),

                  // --- Pestañas de Navegación ---
                  const _DashboardTabs(),

                  const SizedBox(height: 24),

                  // --- Gráfico de Progreso de Proyectos ---
                  const Text(
                    'Progreso de Proyectos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Evolución mensual de proyectos por estado',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _ProjectProgressChart(progressData: data.progressData),

                  const SizedBox(height: 24),

                  // --- Gráfico de Distribución por Tipo ---
                  const Text(
                    'Distribución por Tipo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Proyectos activos por área de consultoría',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _DistributionPieChart(
                    distributionData: data.distributionData,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES PARA LA VISTA ---

class _TimeRangeSelector extends StatelessWidget {
  const _TimeRangeSelector();

  @override
  Widget build(BuildContext context) {
    // Simula el dropdown para 'Últimos 30 días'
    return DropdownButton<String>(
      value: 'Últimos 30 días',
      items: <String>['Últimos 7 días', 'Últimos 30 días', 'Este año']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          })
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          Provider.of<DashboardController>(
            context,
            listen: false,
          ).changeTimeRange(newValue);
        }
      },
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Provider.of<DashboardController>(context, listen: false).exportData();
      },
      icon: const Icon(Icons.download),
      label: const Text('Exportar'),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<MetricCard> metrics;
  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas en móvil
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2.0, // Ajusta la altura de las tarjetas
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      metric.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Indicador de cambio
                    Text(
                      metric.change,
                      style: TextStyle(
                        color: metric.isPositiveChange
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (metric.subtitle != null)
                  Text(
                    metric.subtitle!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardTabs extends StatelessWidget {
  const _DashboardTabs();

  @override
  Widget build(BuildContext context) {
    // Simula la barra de pestañas (Resumen General, Progreso, Recursos, Problemas)
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TabButton(label: 'Resumen General', isSelected: true),
          _TabButton(label: 'Progreso de Proyectos', isSelected: false),
          _TabButton(label: 'Recursos', isSelected: false),
          _TabButton(label: 'Problemas', isSelected: false),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _TabButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: () {
          // Lógica para cambiar de pestaña
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.blue.shade50
              : Colors.transparent,
          side: isSelected ? const BorderSide(color: Colors.blue) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// --- PLACEHOLDERS para Gráficos ---

class _ProjectProgressChart extends StatelessWidget {
  final List<MonthlyProgress> progressData;
  const _ProjectProgressChart({required this.progressData});

  @override
  Widget build(BuildContext context) {
    // **NOTA**: Aquí se usaría un paquete de gráficos como fl_chart para crear el gráfico
    // de área apilada. Este es un placeholder visual.
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'GRÁFICO DE ÁREA APILADA (Progreso de Proyectos)\n\n(Se requiere un paquete como fl_chart)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _DistributionPieChart extends StatelessWidget {
  final List<ProjectDistribution> distributionData;
  const _DistributionPieChart({required this.distributionData});

  @override
  Widget build(BuildContext context) {
    // **NOTA**: Aquí se usaría un paquete de gráficos para crear el gráfico
    // de pastel. Este es un placeholder visual.
    return Row(
      children: [
        // Placeholder del gráfico de pastel
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              'GRÁFICO DE PASTEL',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Leyenda
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: distributionData
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${e.type} ${(e.percentage * 100).toInt()}%'),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
// lib/models/dashboard_model.dart

// ... (Clases MetricCard, ProjectDistribution, MonthlyProgress permanecen iguales)

/// Clase para representar un elemento de la Actividad Reciente.
class RecentActivity {
  final String status;
  final String description;
  final String details; // "Hace X horas - Nombre"
  final IconData icon;
  final Color color;

  RecentActivity({
    required this.status,
    required this.description,
    required this.details,
    required this.icon,
    required this.color,
  });
}

/// Clase para representar un Próximo Vencimiento.
class UpcomingDeadline {
  final String title;
  final String subtitle;
  final String responsible;
  final String priority; // "Alta", "Media", etc.
  final String daysLeft; // "3 días", "5 días", etc.
  final Color priorityColor;

  UpcomingDeadline({
    required this.title,
    required this.subtitle,
    required this.responsible,
    required this.priority,
    required this.daysLeft,
    required this.priorityColor,
  });
}

/// Clase principal que contiene todos los datos del dashboard. (Actualizada)
class DashboardModel {
  // ... (Propiedades existentes)
  final List<MetricCard> metricCards;
  final List<ProjectDistribution> distributionData;
  final List<MonthlyProgress> progressData;

  // NUEVOS DATOS
  final List<RecentActivity> recentActivities;
  final List<UpcomingDeadline> upcomingDeadlines;

  DashboardModel({
    required this.metricCards,
    required this.distributionData,
    required this.progressData,
    required this.recentActivities, // Añadido
    required this.upcomingDeadlines, // Añadido
  });

  /// Método estático para cargar datos de muestra (Simula la carga de una API). (Actualizado)
  static DashboardModel loadSampleData() {
    return DashboardModel(
      // ... (metricCards, distributionData, progressData permanecen iguales)
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

      // NUEVOS DATOS DE MUESTRA
      recentActivities: [
        RecentActivity(
          status: 'Proyecto completado',
          description: 'Análisis de lubricantes industriales finalizado',
          details: 'Hace 2 horas - Dr. Luis Pérez',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        RecentActivity(
          status: 'Tarea asignada',
          description: 'Recolección de muestras asignada a María González',
          details: 'Hace 4 horas - Sistema',
          icon: Icons.assignment_turned_in_outlined,
          color: Colors.blue,
        ),
        RecentActivity(
          status: 'Recurso asignado',
          description: 'Espectrofotómetro UV-Vis reservado para proyecto ABC',
          details: 'Hace 6 horas - Ing. Carlos Rodríguez',
          icon: Icons.devices_other_outlined,
          color: Colors.orange,
        ),
        RecentActivity(
          status: 'Fecha límite próxima',
          description: 'Proyecto XYZ vence en 3 días',
          details: 'Hace 8 horas - Sistema',
          icon: Icons.calendar_today_outlined,
          color: Colors.red,
        ),
      ],
      upcomingDeadlines: [
        UpcomingDeadline(
          title: 'Análisis fisicoquímico',
          subtitle: 'Análisis de Calidad del Agua - Empresa ABC',
          responsible: 'Ing. Carlos Rodríguez',
          priority: 'Alta',
          daysLeft: '3 días',
          priorityColor: Colors.red,
        ),
        UpcomingDeadline(
          title: 'Diseño del plan de manejo',
          subtitle: 'Gestión de Residuos Industriales',
          responsible: 'Dr. María González',
          priority: 'Alta',
          daysLeft: '5 días',
          priorityColor: Colors.red,
        ),
        UpcomingDeadline(
          title: 'Pruebas de viscosidad',
          subtitle: 'Evaluación de Combustibles Alternativos',
          responsible: 'Ing. Carlos Rodríguez',
          priority: 'Media',
          daysLeft: '8 días',
          priorityColor: Colors.orange,
        ),
      ],
    );
  }
}

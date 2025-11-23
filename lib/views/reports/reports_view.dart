import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:provider/provider.dart';
import 'package:prolab_unimet/controllers/reports_controller.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/models/reports_model.dart';
import 'package:fl_chart/fl_chart.dart';

const Map<String, ({String name, Color color, int index})> taskStatusMapping = {
  'pendiente': (name: 'Pendiente', color: Color(0xFF9E9E9E), index: 0),
  'enProgreso': (name: 'En Progreso', color: Color(0xFF2196F3), index: 1),
  'enRevision': (name: 'En Revisión', color: Color(0xFFFF9800), index: 2),
  'completado': (name: 'Completado', color: Color(0xFF4CAF50), index: 3),
};

List<BarChartGroupData> getTaskBarGroups(Map<String, int> taskCounts) {
  return taskStatusMapping.entries.map((entry) {
    final statusKey = entry.key;
    final info = entry.value;
    final count = taskCounts[statusKey] ?? 0;

    return BarChartGroupData(
      x: info.index,
      barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          color: info.color,
          width: 25,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
      showingTooltipIndicators: count > 0 ? [0] : [],
    );
  }).toList();
}

/// Main view for reports and analytics.
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsController()..loadReportsSummary(),
      child: Consumer<ReportsController>(
        builder: (context, controller, _) {
          final ReportsModel model = controller.model;

          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportes y Analytics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Resumen general de proyectos y generación de reportes',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  if (model.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    _buildStatsRow(context, model),
                    const SizedBox(height: 25),
                    _buildGenerateReportCard(context, controller, model),
                    const SizedBox(height: 25),
                    _buildTaskStatusBarChart(context),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the row with the four main statistics.
  Widget _buildStatsRow(BuildContext context, ReportsModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ReportStatCard(
          title: 'Total de proyectos',
          value: model.totalProjects.toString(),
          subtitle: 'Registrados en el sistema',
          color: Colors.indigo,
        ),
        _ReportStatCard(
          title: 'Proyectos completados',
          value: model.completedProjects.toString(),
          subtitle: 'Marcados como finalizados',
          color: Colors.green.shade700,
        ),
        _ReportStatCard(
          title: 'En progreso',
          value: model.inProgressProjects.toString(),
          subtitle: 'Actualmente en ejecución',
          color: Colors.blue.shade700,
        ),
        _ReportStatCard(
          title: 'Presupuesto promedio',
          value: '\$${model.averageBudgetUsd.toStringAsFixed(0)}',
          subtitle: 'Por proyecto (USD)',
          color: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _buildTaskStatusBarChart(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxWidth = 600.0;
    final double chartWidth = screenWidth * 0.95 > maxWidth
        ? maxWidth
        : screenWidth * 0.95;

    if (taskController.currentProjectId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Selecciona un proyecto para ver la distribución de tareas.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<Map<String, int>>(
      stream: taskController.streamTaskStatusCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        final counts = snapshot.data ?? {};
        final barGroups = getTaskBarGroups(counts);

        final maxY = counts.values.isEmpty
            ? 10.0
            : counts.values.reduce((a, b) => a > b ? a : b) + 2.0;

        return Center(
          child: SizedBox(
            width: chartWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribución de Tareas por Estado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 250,
                  padding: const EdgeInsets.only(
                    top: 10,
                    right: 10,
                    left: 10,
                    bottom: 0,
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      groupsSpace: 12,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final statusInfo = taskStatusMapping.values
                                  .firstWhere(
                                    (e) => e.index == value.toInt(),
                                    orElse: () => (
                                      name: '',
                                      color: Colors.transparent,
                                      index: -1,
                                    ),
                                  );
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4.0,
                                child: Text(
                                  statusInfo.name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xff37434d),
                            width: 1,
                          ),
                          left: BorderSide.none,
                          right: BorderSide.none,
                          top: BorderSide.none,
                        ),
                      ),
                      barGroups: barGroups,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Card with button to open the generate-report dialog.
  Widget _buildGenerateReportCard(
    BuildContext context,
    ReportsController controller,
    ReportsModel model,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.green.shade200),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generar reporte de proyecto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Selecciona un proyecto para generar un reporte en PDF con sus detalles principales.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      GenerateProjectReportDialog(controller: controller),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar reporte'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small card for a single statistic.
class _ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _ReportStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal that allows the user to pick a project and generate a PDF report.
class GenerateProjectReportDialog extends StatefulWidget {
  final ReportsController controller;

  const GenerateProjectReportDialog({super.key, required this.controller});

  @override
  State<GenerateProjectReportDialog> createState() =>
      _GenerateProjectReportDialogState();
}

class _GenerateProjectReportDialogState
    extends State<GenerateProjectReportDialog> {
  Project? _selectedProject;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xff253f8d)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Generar reporte de proyecto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff253f8d),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isGenerating
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecciona el proyecto para generar el reporte en PDF.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<Project>>(
                future: widget.controller.fetchProjectsForReport(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Error al cargar proyectos. Inténtalo nuevamente.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    );
                  }

                  final projects = snapshot.data ?? [];

                  if (projects.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No se encontraron proyectos para generar reportes.',
                      ),
                    );
                  }

                  return DropdownButtonFormField<Project>(
                    decoration: InputDecoration(
                      labelText: 'Proyecto',
                      hintText: 'Selecciona un proyecto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedProject,
                    items: projects.map((project) {
                      final title = project.name.isEmpty
                          ? 'Sin título'
                          : project.name;
                      return DropdownMenuItem<Project>(
                        value: project,
                        child: Text(
                          '$title (${project.id.substring(0, 6)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _isGenerating
                        ? null
                        : (value) {
                            setState(() {
                              _selectedProject = value;
                            });
                          },
                  );
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isGenerating
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating
                          ? null
                          : () async {
                              if (_selectedProject == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Selecciona un proyecto antes de generar el reporte.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isGenerating = true;
                              });

                              await widget.controller.generateProjectReportPdf(
                                context,
                                _selectedProject!,
                              );

                              if (mounted) {
                                setState(() {
                                  _isGenerating = false;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(
                        _isGenerating ? 'Generando...' : 'Generar PDF',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff253f8d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

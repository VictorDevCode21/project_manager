import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/homepage_controller.dart';
import '../models/homepage_model.dart';
import 'package:go_router/go_router.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageController(),
      child: Consumer<HomePageController>(
        builder: (context, controller, child) {
          final model = controller.model;
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Bienvenido a ProLab UNIMET',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistema de Gestión de Proyectos - Laboratorios de Ingeniería',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  _buildKPIsRow(context, model),
                  const SizedBox(height: 25),

                  _buildManagementCards(context, controller),
                  const SizedBox(height: 25),

                  _buildBottomCards(context, controller),
                  const SizedBox(height: 25),

                  _buildRecentProjects(context, model, controller),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentProjects(
    BuildContext context,
    HomePageModel model,
    HomePageController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proyectos Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Últimos proyectos creados y actualizados',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 15),

        ...model.recentProjects.map((project) {
          return _ProjectTile(
            project: project,
            onPressed: () => controller.goToProjectDetails(context, project.id),
          );
        }),
      ],
    );
  }

  Widget _buildKPIsRow(BuildContext context, HomePageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _KPIWidget(
          title: 'Proyectos Activos',
          value: model.activeProjects.toString(),
          icon: Icons.folder_open,
          secondaryText: '+${model.expiringThisMonth} este mes',
          secondaryColor: Colors.green,
        ),
        _KPIWidget(
          title: 'Tareas Pendientes',
          value: model.pendingTasks.toString(),
          icon: Icons.pending_actions,
          secondaryText: '${model.dueSoon} vencen pronto',
          secondaryColor: Colors.orange,
        ),
        _KPIWidget(
          title: 'Recursos Asignados',
          value: '${model.resourceUtilization}%',
          icon: Icons.people_alt,
          secondaryText: 'Utilización actual',
          secondaryColor: Colors.blue,
        ),
        _KPIWidget(
          title: 'Progreso General',
          value: '${model.generalProgress}%',
          icon: Icons.show_chart,
          secondaryText: 'En tiempo',
          secondaryColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildManagementCards(
    BuildContext context,
    HomePageController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _ManagementCard(
            icon: Icons.list_alt,
            title: 'Gestión de Proyectos',
            subtitle: 'Crear, editar y monitorear proyectos de consultoría',
            primaryButtonText: 'Ver Todos los Proyectos',
            primaryOnPressed: () => controller.goToAllProjects(context),
            secondaryButtonText: 'Crear Nuevo Proyecto',
            secondaryOnPressed: () => controller.goToCreateProject(context),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ManagementCard(
            icon: Icons.calendar_today,
            title: 'Gestión de Tareas',
            subtitle: 'Asignar y monitorear tareas de proyectos',
            primaryButtonText: 'Ver Todas las Tareas',
            primaryOnPressed: () => controller.goToAllTasks(context),
            secondaryButtonText: 'Crear Nueva Tarea',
            secondaryOnPressed: () => controller.goToCreateTask(context),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ManagementCard(
            icon: Icons.people_alt,
            title: 'Gestión de Recursos',
            subtitle: 'Asignar personal y materiales a proyectos',
            primaryButtonText: 'Ver Recursos Disponibles',
            // Aquí: ir directo a /admin-resources
            primaryOnPressed: () => context.go('/admin-resources'),
            secondaryButtonText: 'Asignar Recursos',
            // Aquí: abrir flujo/modal de asignación en /admin-resources/assign
            secondaryOnPressed: () => context.go('/admin-resources/assign'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCards(
    BuildContext context,
    HomePageController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Expanded(
        //   child: _ManagementCard(
        //     icon: Icons.bar_chart,
        //     title: 'Dashboard y Seguimiento',
        //     subtitle: 'Monitorear progreso en tiempo real',
        //     primaryButtonText: 'Ver Dashboard',
        //     primaryOnPressed: () => controller.goToDashboard(context),
        //     secondaryButtonText: 'Ver Progreso de Proyectos',
        //     secondaryOnPressed: () => controller.goToProjectProgress(context),
        //   ),
        // ),
        // const SizedBox(width: 20),
        // Expanded(
        //   child: _ManagementCard(
        //     icon: Icons.analytics,
        //     title: 'Reportes y Analytics',
        //     subtitle: 'Generar reportes y análisis detallados',
        //     primaryButtonText: 'Ver Reportes',
        //     primaryOnPressed: () => controller.goToReports(context),
        //     secondaryButtonText: 'Generar Nuevo Reporte',
        //     secondaryOnPressed: () => controller.goToGenerateReport(context),
        //   ),
        // ),
        const Spacer(),
      ],
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AppBarButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: () {
        // ignore: avoid_print
        print('Navegando a: $label');
      },
    );
  }
}

class _KPIWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String secondaryText;
  final Color secondaryColor;

  const _KPIWidget({
    required this.title,
    required this.value,
    required this.icon,
    required this.secondaryText,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              secondaryText,
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final VoidCallback? primaryOnPressed;
  final String secondaryButtonText;
  final VoidCallback? secondaryOnPressed;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    this.primaryOnPressed,
    required this.secondaryButtonText,
    this.secondaryOnPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.green.shade200),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: primaryOnPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black54,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.green.shade200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(primaryButtonText),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: secondaryOnPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFFF9900),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title.contains('Crear') ||
                      title.contains('Generar') ||
                      title.contains('Asignar'))
                    const Icon(Icons.add, size: 20),
                  const SizedBox(width: 5),
                  Text(secondaryButtonText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback onPressed;

  const _ProjectTile({required this.project, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Color progressColor = Colors.grey;
    if (project.progress == 100) {
      progressColor = Colors.green.shade600;
    } else if (project.progress >= 50) {
      progressColor = Colors.blue.shade600;
    } else {
      progressColor = Colors.orange.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.title} - ${project.client}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Tag(label: project.category, color: Colors.teal),
                    const SizedBox(width: 8),
                    _Tag(
                      label: project.status,
                      color: project.status == 'Completado'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          const SizedBox(width: 5),
          Text(project.dueDate, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 20),
          SizedBox(
            width: 150,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${project.progress}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: project.progress / 100,
                    color: progressColor,
                    backgroundColor: progressColor.withOpacity(0.2),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.remove_red_eye, size: 18),
            label: const Text('Ver Detalles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black54,
              side: BorderSide(color: Colors.green.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

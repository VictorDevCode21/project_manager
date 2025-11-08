import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/project_controller.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/views/components/forms/create_project.dart';
import 'package:provider/provider.dart';

/// Displays the projects management view inside AdminLayout.
class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Todos los estados';
  String _selectedType = 'Todos los tipos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== PAGE HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Proyectos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1a1a1a),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Administrar proyectos de consultoría',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context, rootNavigator: true);
                      final messenger = ScaffoldMessenger.of(context);

                      // 1) Abre el diálogo UI (solo recoge datos)
                      final dto = await showDialog<ProjectCreateData>(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: true, // opcional, pero consistente
                        builder: (_) => const CreateProjectDialog(),
                      );
                      if (dto == null) return;

                      // Guard against using BuildContext across async gaps.
                      if (!mounted) return;

                      debugPrint(
                        '[ProjectsView] DTO -> '
                        'name=${dto.name}, client=${dto.client}, '
                        'desc.len=${dto.description.length}, type=${dto.consultingType}, '
                        'budget=${dto.budgetUsd}, priority=${dto.priority}, '
                        'start=${dto.startDate.toIso8601String()}, '
                        'end=${dto.endDate.toIso8601String()}',
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: true,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final controller = ProjectController();
                        final projectId = await controller.createProject(
                          name: dto.name,
                          client: dto.client,
                          description: dto.description,
                          consultingType: dto.consultingType,
                          budgetUsd: dto.budgetUsd,
                          priority: dto.priority,
                          startDate: dto.startDate,
                          endDate: dto.endDate,
                        );

                        if (!mounted) return;
                        if (nav.canPop()) {
                          nav.pop();
                        }

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Proyecto creado: $projectId'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        if (nav.canPop()) {
                          nav.pop(); // cierra loader también en error
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error al crear: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      'Nuevo Proyecto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff253f8d),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ===== FILTER SECTION =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros y Búsqueda',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff253f8d),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText:
                                  'Buscar por nombre de proyecto o cliente...',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Status filter
                        DropdownButton<String>(
                          value: _selectedStatus,
                          items:
                              [
                                    'Todos los estados',
                                    'En Progreso',
                                    'Planificación',
                                    'Completado',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value!);
                          },
                        ),
                        const SizedBox(width: 16),

                        // Type filter
                        DropdownButton<String>(
                          value: _selectedType,
                          items:
                              [
                                    'Todos los tipos',
                                    'Calidad Ambiental',
                                    'Construcción',
                                    'Tecnología',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value!);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ===== PROJECTS GRID =====
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final controller = ProjectController();

                  return StreamBuilder<List<Project>>(
                    stream: controller.streamOwnedProjects(),
                    builder: (context, snap) {
                      // Loading state
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Error state
                      if (snap.hasError) {
                        // Log error details to the console for debugging.
                        // Use debugPrint (non-blocking) instead of print for Flutter apps.
                        debugPrint(
                          '[ProjectsView] stream error: ${snap.error}',
                        );
                        if (snap.stackTrace != null) {
                          debugPrint(
                            '[ProjectsView] stack: ${snap.stackTrace}',
                          );
                        }

                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Error cargando proyectos: ${snap.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      final projects = (snap.data ?? const <Project>[])
                          // Optional client-side filter by status
                          .where((p) {
                            if (_selectedStatus == 'Todos los estados')
                              return true;
                            switch (_selectedStatus) {
                              case 'Planificación':
                                return p.status == ProjectStatus.planning;
                              case 'En Progreso':
                                return p.status == ProjectStatus.inProgress;
                              case 'Completado':
                                return p.status == ProjectStatus.completed;
                            }
                            return true;
                          })
                          // Optional client-side filter by type
                          .where((p) {
                            if (_selectedType == 'Todos los tipos') return true;
                            return p.consultingType.trim().toLowerCase() ==
                                _selectedType.trim().toLowerCase();
                          })
                          // Optional search
                          .where((p) {
                            final q = _searchController.text
                                .trim()
                                .toLowerCase();
                            if (q.isEmpty) return true;
                            return p.name.toLowerCase().contains(q) ||
                                p.client.toLowerCase().contains(q);
                          })
                          .toList();

                      if (projects.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const Text(
                            'No hay proyectos para mostrar.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return GridView.count(
                        crossAxisCount: isWide ? 2 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        shrinkWrap: true,
                        childAspectRatio: isWide ? 1.7 : 1.4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: projects.map((p) {
                          // Build tags from real data
                          final tags = <String>[
                            // Status tag
                            () {
                              switch (p.status) {
                                case ProjectStatus.planning:
                                  return 'Planificación';
                                case ProjectStatus.inProgress:
                                  return 'En Progreso';
                                case ProjectStatus.completed:
                                  return 'Completado';
                                case ProjectStatus.archived:
                                  return 'Archivado';
                              }
                            }(),
                            // Type tag (if present)
                            if (p.consultingType.isNotEmpty) p.consultingType,
                          ];

                          // Null-ish displays as zero/empty
                          final client = p.client.isNotEmpty ? p.client : '—';
                          final team =
                              '0 miembros'; // until you wire members count
                          final deadline =
                              '${p.endDate.day.toString().padLeft(2, '0')}/${p.endDate.month.toString().padLeft(2, '0')}/${p.endDate.year}';
                          final budget = '\$${p.budgetUsd.toStringAsFixed(0)}';

                          // Optional progress until you implement it in data (0 by default)
                          final progress = 0.0;

                          return _buildProjectCard(
                            title: p.name.isNotEmpty
                                ? p.name
                                : 'Proyecto sin título',
                            description: p.description.isNotEmpty
                                ? p.description
                                : 'Sin descripción',
                            tags: tags,
                            progress: progress,
                            client: client,
                            team: team,
                            deadline: deadline,
                            budget: budget,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single project card with consistent design.
  Widget _buildProjectCard({
    required String title,
    required String description,
    required List<String> tags,
    required double progress,
    required String client,
    required String team,
    required String deadline,
    required String budget,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xff253f8d),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),

          // Tags
          Wrap(spacing: 6, children: tags.map((t) => _buildTag(t)).toList()),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso', style: TextStyle(color: Colors.black54)),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff253f8d)),
          ),
          const SizedBox(height: 16),

          // Info section
          _buildInfoRow('Cliente:', client),
          _buildInfoRow('Equipo:', team),
          _buildInfoRow('Entrega:', deadline),
          _buildInfoRow('Presupuesto:', budget),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Ver Detalles'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff253f8d),
                  ),
                  child: const Text(
                    'Gestionar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper for rendering project tags.
  Widget _buildTag(String label) {
    Color bg;
    switch (label) {
      case 'En Progreso':
        bg = const Color(0xffe3f2fd);
        break;
      case 'Calidad Ambiental':
        bg = const Color(0xffe8f5e9);
        break;
      case 'Planificación':
        bg = const Color(0xfffff3e0);
        break;
      case 'Construcción':
        bg = const Color(0xffffebee);
        break;
      default:
        bg = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  /// Helper for displaying labeled rows.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

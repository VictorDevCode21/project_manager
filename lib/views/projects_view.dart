import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/consulting_type_controller.dart';
import 'package:prolab_unimet/controllers/project_controller.dart';
import 'package:prolab_unimet/models/projects_model.dart';
import 'package:prolab_unimet/views/components/forms/create_project.dart';
import 'package:prolab_unimet/views/projects/manage_members_dialog.dart';
import 'package:prolab_unimet/views/projects/project_details_dialog.dart';
import 'package:prolab_unimet/widgets/app_dropdown.dart';
import 'package:intl/intl.dart';

/// Projects management view inside AdminLayout (View layer - MVC).
class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  final TextEditingController _searchController = TextEditingController();
  final controller = ProjectController();

  // UI filter state
  String _selectedStatus = 'Todos los estados';
  String _selectedType = 'Todos los tipos';

  // Debounce for search box
  Timer? _searchDebounce;

  // Single instance for consulting types
  late final ConsultingTypeController _ctController;

  // Currency formatter for budget
  late final NumberFormat _budgetFormatter;

  @override
  void initState() {
    super.initState();
    _ctController = ConsultingTypeController();
    _searchController.addListener(_onSearchChanged);

    // Initialize currency formatter (locale in Spanish style)
    _budgetFormatter = NumberFormat.currency(
      locale: 'es_VE', // or 'es_ES', 'es_MX', etc.
      symbol: r'$',
      decimalDigits: 0,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Debounced text change
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() {});
    });
  }

  /// Apply filters client-side for simplicity
  List<Project> _filterProjects(List<Project> source) {
    // 1) Status
    final byStatus = source.where((p) {
      if (_selectedStatus == 'Todos los estados') return true;
      switch (_selectedStatus) {
        case 'Planificación':
          return p.status == ProjectStatus.planning;
        case 'En Progreso':
          return p.status == ProjectStatus.inProgress;
        case 'Completado':
          return p.status == ProjectStatus.completed;
        case 'Archivado':
          return p.status == ProjectStatus.archived;
      }
      return true;
    });

    // 2) Type
    final byType = byStatus.where((p) {
      if (_selectedType == 'Todos los tipos') return true;
      return p.consultingType.trim().toLowerCase() ==
          _selectedType.trim().toLowerCase();
    });

    // 3) Search by name or client
    final query = _searchController.text.trim().toLowerCase();
    final bySearch = byType.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.client.toLowerCase().contains(query);
    });

    return bySearch.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Proyectos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
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

                      // 1) Open modal to create project
                      final dto = await showDialog<ProjectCreateData>(
                        context: context,
                        barrierDismissible: false,
                        useRootNavigator: true,
                        builder: (_) => const CreateProjectDialog(),
                      );
                      if (dto == null) return;
                      if (!mounted) return;

                      // 2) Progress spinner while creating
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
                        if (nav.canPop()) nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Proyecto creado con id: $projectId'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        if (nav.canPop()) nav.pop();
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
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

              // ===== FILTERS =====
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
                    Text(
                      'Filtros y Búsqueda',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
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
                        // Status
                        SizedBox(
                          width: 220,
                          height: 52,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedStatus,
                                items:
                                    const [
                                      'Todos los estados',
                                      'En Progreso',
                                      'Planificación',
                                      'Completado',
                                      // 'Archivado'
                                    ].map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedStatus = value);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Type
                        SizedBox(
                          width: 260,
                          height: 52,
                          child: StreamBuilder<List<String>>(
                            stream: _ctController.streamConsultingTypeNames(),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                      ConnectionState.waiting &&
                                  !snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snap.hasError) {
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Error cargando tipos',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              final base = (snap.data ?? const <String>[])
                                  .where((e) => e.trim().isNotEmpty)
                                  .toList();
                              final options = ['Todos los tipos', ...base];
                              final current = options.contains(_selectedType)
                                  ? _selectedType
                                  : 'Todos los tipos';

                              return AppDropdown<String>(
                                items: options,
                                value: current,
                                labelOf: (x) => x,
                                hintText: 'Tipo de consultoría',
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() => _selectedType = val);
                                },
                                validator: (_) => null,
                              );
                            },
                          ),
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
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snap.hasError) {
                        debugPrint(
                          '[ProjectsView] stream error: ${snap.error}',
                        );
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

                      final projects = _filterProjects(snap.data ?? const []);
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
                          return _buildProjectCard(
                            project: p,
                            onManage: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => ManageMembersDialog(
                                  projectId: p.id,
                                  projectName: p.name,
                                ),
                              );
                            },
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

  /// Single project card. Receives the full `Project` to avoid dangling vars.
  Widget _buildProjectCard({
    required Project project,
    required VoidCallback onManage,
  }) {
    // Build tags
    final tags = <String>[
      switch (project.status) {
        ProjectStatus.planning => 'Planificación',
        ProjectStatus.inProgress => 'En Progreso',
        ProjectStatus.completed => 'Completado',
        ProjectStatus.archived => 'Archivado',
      },
      if (project.consultingType.isNotEmpty) project.consultingType,
    ];

    // Derived UI strings
    final title = project.name.isNotEmpty
        ? project.name
        : 'Proyecto sin título';
    final description = project.description.isNotEmpty
        ? project.description
        : 'Sin descripción';
    final client = project.client.isNotEmpty ? project.client : '—';

    // Team count based on visibleTo
    final int memberCount = project.visibleTo.length - 1;
    final String team;
    if (memberCount <= 0) {
      team = 'Sin miembros';
    } else if (memberCount == 1) {
      team = '1 miembro';
    } else {
      team = '$memberCount miembros';
    }

    final deadline =
        '${project.endDate.day.toString().padLeft(2, '0')}/${project.endDate.month.toString().padLeft(2, '0')}/${project.endDate.year}';
    final String budget = _budgetFormatter.format(project.budgetUsd);
    final progress = 0.0; // Placeholder for now

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
          // Title & description
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Tags
          Wrap(spacing: 6, children: tags.map((t) => _buildTag(t)).toList()),
          const SizedBox(height: 12),

          // Progress
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

          // Info rows
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => ProjectDetailsDialog(project: project),
                    );
                  },
                  child: const Text('Ver Detalles'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onManage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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

  /// Tag chip
  Widget _buildTag(String label) {
    Color bg;
    switch (label) {
      case 'En Progreso':
        bg = const Color(0xffe3f2fd);
        break;
      case 'Planificación':
        bg = const Color(0xfffff3e0);
        break;
      case 'Completado':
        bg = const Color(0xffe8f5e9);
        break;
      case 'Archivado':
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

  /// Key-value row
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

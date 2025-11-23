// lib/views/projects/project_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/project_controller.dart';
import 'package:prolab_unimet/models/projects_model.dart';

class ProjectDetailsDialog extends StatelessWidget {
  final Project project;
  final ProjectController _controller;

  ProjectDetailsDialog({
    super.key,
    required this.project,
    ProjectController? controller,
  }) : _controller = controller ?? ProjectController();

  // Builds a soft badge similar to the cards' style
  Widget _chip(String label, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  // Map project status to Spanish label + soft color
  (String, Color) _statusUi() {
    switch (project.status) {
      case ProjectStatus.planning:
        return ('Planificación', const Color(0xfffff3e0));
      case ProjectStatus.inProgress:
        return ('En Progreso', const Color(0xffe3f2fd));
      case ProjectStatus.completed:
        return ('Completado', Colors.green.shade50);
      case ProjectStatus.archived:
        return ('Archivado', Colors.grey.shade200);
    }
  }

  // Simple key-value row
  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              v.isEmpty ? '—' : v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    // Fixed but responsive height so content scrolls inside modal
    final maxW = 760.0;
    final screenH = MediaQuery.of(context).size.height;
    final contentH = screenH * 0.75; // 75% of viewport height

    final (statusLabel, statusColor) = _statusUi();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xff253f8d)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Detalles del Proyecto • ${project.name.isEmpty ? 'Sin título' : project.name}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff253f8d),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tags row
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(statusLabel, bg: statusColor),
                    if (project.consultingType.isNotEmpty)
                      _chip(
                        project.consultingType,
                        bg: const Color(0xffe8f5e9),
                      ),
                    if (project.priority == ProjectPriority.high)
                      _chip('Alta', bg: Colors.red.shade50),
                    if (project.priority == ProjectPriority.medium)
                      _chip('Media', bg: Colors.orange.shade50),
                    if (project.priority == ProjectPriority.low)
                      _chip('Baja', bg: Colors.blueGrey.shade50),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable content area
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxHeight: contentH),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Description block
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Descripción',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            project.description.isNotEmpty
                                ? project.description
                                : 'Sin descripción.',
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Key details grid
                        LayoutBuilder(
                          builder: (context, c) {
                            final isWide = c.maxWidth > 520;
                            final left = Column(
                              children: [
                                _kv('Cliente', project.client),
                                _kv(
                                  'Presupuesto',
                                  '\$${project.budgetUsd.toStringAsFixed(2)}',
                                ),
                                _kv('Inicio', _formatDate(project.startDate)),
                                _kv('Entrega', _formatDate(project.endDate)),
                              ],
                            );
                            final right = Column(
                              children: [
                                _kv('Propietario (UID)', project.ownerId),
                                _kv('ID del proyecto', project.id),
                                _kv('Creado', _formatDate(project.createdAt)),
                              ],
                            );

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: left),
                                  const SizedBox(width: 16),
                                  Expanded(child: right),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                left,
                                const SizedBox(height: 12),
                                right,
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Members count (live)
                        Row(
                          children: [
                            const Icon(
                              Icons.group_outlined,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Miembros',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            StreamBuilder<List<ProjectMember>>(
                              stream: _controller.streamMembers(project.id),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                final n = (snap.data ?? const <ProjectMember>[])
                                    .length;
                                return Text(
                                  '$n miembro${n == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

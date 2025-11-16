import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

/// Shows a read-only view of a task with options to edit or delete it.
class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final String assigneeDisplayName;
  final String projectName;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.assigneeDisplayName,
    required this.projectName,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        task.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xff253f8d),
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Proyecto:', projectName),
              const SizedBox(height: 8),
              _buildDetailRow('Responsable:', assigneeDisplayName),
              const SizedBox(height: 8),
              _buildDetailRow('Estado:', _getStatusText(task.status)),
              const SizedBox(height: 8),
              _buildDetailRow('Prioridad:', _getPriorityText(task.priority)),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Horas estimadas:',
                '${task.estimatedHours.toInt()} h',
              ),
              const SizedBox(height: 16),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff253f8d),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task.description.isEmpty ? 'Sin descripción' : task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: task.description.isEmpty
                      ? Colors.grey
                      : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDeletePressed,
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar', style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton(
          onPressed: onEditPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2d55fa),
          ),
          child: const Text('Editar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /// Builds a single row with label and value.
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xff253f8d),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  /// Returns Spanish text for status.
  String _getStatusText(Status status) {
    switch (status) {
      case Status.pendiente:
        return 'Pendiente';
      case Status.enProgreso:
        return 'En Progreso';
      case Status.enRevision:
        return 'En Revisión';
      case Status.completado:
        return 'Completado';
    }
  }

  /// Returns Spanish text for priority.
  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Baja';
      case Priority.medium:
        return 'Media';
      case Priority.high:
        return 'Alta';
    }
  }
}

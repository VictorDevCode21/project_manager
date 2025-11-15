import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Detalles de la Tarea',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xff253f8d),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff253f8d),
                ),
              ),
              SizedBox(height: 16),

              if (task.description.isNotEmpty) ...[
                Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                SizedBox(height: 16),
              ],

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Proyecto:', task.projectType),
                    _buildDetailRow('Asignado a:', task.assignee),
                    _buildDetailRow(
                      'Prioridad:',
                      _getPriorityText(task.priority),
                    ),
                    _buildDetailRow('Estado:', _getStatusText(task.status)),
                    _buildDetailRow(
                      'Horas estimadas:',
                      '${task.estimatedHours} h',
                    ),
                    if (task.dueTime != null)
                      _buildDetailRow(
                        'Fecha límite:',
                        _formatDate(task.dueTime!),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDeletePressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                      child: Text('Eliminar'),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEditPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff253f8d),
                      ),
                      child: Text(
                        'Editar Tarea',
                        style: TextStyle(color: Colors.white),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.alta:
        return 'Alta';
      case Priority.media:
        return 'Media';
      case Priority.baja:
        return 'Baja';
    }
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

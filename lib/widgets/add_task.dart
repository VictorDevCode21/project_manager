//import 'package:flutter/material.dart' show AlertDialog;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

class AddTask extends StatefulWidget {
  final List<TaskColumn> columns;
  final Function(Task) onAddTask;

  const AddTask({super.key, required this.columns, required this.onAddTask});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  String _selectedtProjectType = 'Calidad ambiental';
  String _selectedAssignee = 'Maria';
  Priority _selectedPriority = Priority.media;
  Status _selectedStatus = Status.pendiente;
  TaskColumn? _selectedColumn;

  final List<String> _projectTypes = [
    'Calidad Ambiental',
    'Construcción',
    'Tecnología',
  ];

  final List<String> _assignees = ['Maria', 'Juan', 'Alcachofa'];

  @override
  void initState() {
    super.initState();
    if (widget.columns.isNotEmpty) {
      _selectedColumn = widget.columns.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: EdgeInsets.all(16),
      actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      title: Text(
        'Crear nueva tarea',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xff253f8d),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título de la tarea',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proyecto', style: TextStyle(fontSize: 14)),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedtProjectType,
                        items: _projectTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedtProjectType = value!);
                        },
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asignado', style: TextStyle(fontSize: 14)),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAssignee,
                        items: _assignees.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedAssignee = value!);
                        },
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Row(
                  children: [
                    // Prioridad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prioridad', style: TextStyle(fontSize: 12)),
                          DropdownButtonFormField<Priority>(
                            initialValue: _selectedPriority,
                            items: Priority.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  _getPriorityText(priority),
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedPriority = value!);
                            },
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado', style: TextStyle(fontSize: 12)),
                          DropdownButtonFormField<Status>(
                            initialValue: _selectedStatus,
                            items: Status.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedStatus = value!);
                            },
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.baja:
        return 'Baja';
      case Priority.media:
        return 'Media';
      case Priority.alta:
        return 'Alta';
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }
}

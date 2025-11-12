//import 'package:flutter/material.dart' show AlertDialog;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/tasks_model.dart';
import 'package:flutter/material.dart' show AlertDialog;

class AddTask extends StatefulWidget {
  final List<TaskColumn> columns;
  final Function(Task) onAddTask;
  final String projectId;

  const AddTask({
    super.key,
    required this.columns,
    required this.onAddTask,
    required this.projectId,
  });

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  String? _selectedtProjectType;
  String? _selectedAssignee;
  Priority? _selectedPriority;
  Status? _selectedStatus;
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
    _selectedtProjectType = _projectTypes.first;
    _selectedAssignee = _assignees.first;
    _selectedPriority = Priority.media;
    _selectedStatus = Status.pendiente;
    if (widget.columns.isNotEmpty) {
      _selectedColumn = widget.columns.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: EdgeInsets.all(16),
      title: Text(
        'Crear nueva tarea',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xff253f8d),
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
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
                maxLines: 3,
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
                          value: _selectedtProjectType,
                          items: _projectTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type, style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedtProjectType = value);
                          },
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asignado', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<String>(
                          value: _selectedAssignee,
                          items: _assignees.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type, style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedAssignee = value);
                          },
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prioridad', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<Priority>(
                          value: _selectedPriority,
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
                            setState(() => _selectedPriority = value);
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
                        Text('Estado', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<Status>(
                          value: _selectedStatus,
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
                            setState(() => _selectedStatus = value);
                          },
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Horas estimadas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Columna', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<TaskColumn>(
                          value: _selectedColumn,
                          items: widget.columns.map((column) {
                            return DropdownMenuItem(
                              value: column,
                              child: Text(
                                column.name,
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedColumn = value);
                          },
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton(
          onPressed: _titleController.text.trim().isEmpty
              ? null
              : () {
                  final newTask = Task(
                    projectId: widget.projectId,
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    projectType: _selectedtProjectType ?? 'Calidad Ambiental',
                    assignee: _selectedAssignee ?? 'Maria',
                    priority: _selectedPriority ?? Priority.media,
                    status: _selectedStatus ?? Status.pendiente,
                    estimatedHours: double.tryParse(_hoursController.text) ?? 0,
                    dueTime: null,
                    tags: [],
                  );

                  widget.onAddTask(newTask);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2d55fa),
          ),
          child: Text('Crear Tarea', style: TextStyle(color: Colors.white)),
        ),
      ],
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

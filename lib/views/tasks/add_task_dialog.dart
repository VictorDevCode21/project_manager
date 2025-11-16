import 'package:flutter/material.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

class AddTask extends StatefulWidget {
  final List<TaskColumn> columns;
  final Function(Task)? onAddTask;
  final String projectId;
  final Function(Task)? onUpdateTask;
  final Task? task;

  /// Project type used for storage, not editable from UI.
  final String projectType;

  /// Human readable project name to show in the dialog.
  final String projectName;

  /// Project members list (id + name).
  final List<Map<String, String>> projectMembers;

  const AddTask({
    super.key,
    required this.columns,
    this.onAddTask,
    required this.projectId,
    this.onUpdateTask,
    this.task,
    required this.projectType,
    required this.projectName,
    required this.projectMembers,
  });

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  String? _selectedProjectType;
  String? _selectedAssigneeId;
  Priority? _selectedPriority;
  Status? _selectedStatus;
  TaskColumn? _selectedColumn;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      // Editing existing task
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _hoursController.text = widget.task!.estimatedHours.toInt().toString();
      _selectedProjectType = widget.task!.projectType;
      _selectedAssigneeId = widget.task!.assignee;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
    } else {
      // New task defaults
      _selectedProjectType = widget.projectType;
      _selectedPriority = Priority.medium;
      _selectedStatus = Status.pendiente;

      if (widget.projectMembers.isNotEmpty) {
        _selectedAssigneeId = widget.projectMembers.first['id'];
      }
    }

    if (widget.columns.isNotEmpty) {
      _selectedColumn = widget.columns.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        isEditing ? 'Editar tarea' : 'Crear nueva tarea',
        style: const TextStyle(
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
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Project name (read only)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proyecto: ${widget.projectName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Assignee (project member)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Asignado', style: TextStyle(fontSize: 14)),
                        if (widget.projectMembers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Este proyecto no tiene miembros asignados.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedAssigneeId,
                            items: widget.projectMembers.map((member) {
                              return DropdownMenuItem(
                                value: member['id'],
                                child: Text(
                                  member['name'] ?? 'Sin nombre',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedAssigneeId = value);
                            },
                            isExpanded: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prioridad', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<Priority>(
                          value: _selectedPriority,
                          items: Priority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                _getPriorityText(priority),
                                style: const TextStyle(fontSize: 14),
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
                  const SizedBox(width: 12),
                  // Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estado', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<Status>(
                          value: _selectedStatus,
                          items: Status.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                _getStatusText(status),
                                style: const TextStyle(fontSize: 14),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  // Estimated hours
                  Expanded(
                    child: TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Horas estimadas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Columna', style: TextStyle(fontSize: 14)),
                        DropdownButtonFormField<TaskColumn>(
                          value: _selectedColumn,
                          items: widget.columns.map((column) {
                            return DropdownMenuItem(
                              value: column,
                              child: Text(
                                column.name,
                                style: const TextStyle(fontSize: 14),
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
              const SizedBox(height: 16),
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
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2d55fa),
          ),
          child: Text(
            isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Handles form submission with regex validation.
  void _handleSubmit() {
    final RegExp onlyDigitsRegex = RegExp(r'^\d+$');
    final RegExp integerRegex = RegExp(r'^[0-9]+$');

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String hoursText = _hoursController.text.trim();

    final List<String> errors = <String>[];

    // Title: required, at least 3 chars, not only numbers
    if (title.isEmpty) {
      errors.add('El título es obligatorio.');
    } else if (title.length < 3) {
      errors.add('El título debe tener al menos 3 caracteres.');
    } else if (onlyDigitsRegex.hasMatch(title)) {
      errors.add('El título no puede ser solo numérico.');
    }

    // Description: optional, but cannot be only numbers
    if (description.isNotEmpty && onlyDigitsRegex.hasMatch(description)) {
      errors.add('La descripción no puede ser solo numérica.');
    }

    // Hours: required, integer only, no decimals
    if (hoursText.isEmpty) {
      errors.add('Las horas estimadas son obligatorias.');
    } else if (!integerRegex.hasMatch(hoursText)) {
      errors.add(
        'Las horas estimadas deben ser un número entero (sin decimales).',
      );
    }

    // Assignee: cannot be null or empty
    if (_selectedAssigneeId == null || _selectedAssigneeId!.trim().isEmpty) {
      errors.add('Debes seleccionar un responsable.');
    }

    // Status: cannot be null
    if (_selectedStatus == null) {
      errors.add('Debes seleccionar un estado.');
    }

    // Column: cannot be null
    if (_selectedColumn == null) {
      errors.add('Debes seleccionar una columna.');
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.join('\n')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final int parsedHours = int.parse(hoursText);

    final Task task = Task(
      id: widget.task?.id ?? '',
      projectId: widget.projectId,
      title: title,
      description: description,
      projectType: _selectedProjectType ?? widget.projectType,
      assignee: _selectedAssigneeId!,
      priority: _selectedPriority ?? Priority.medium,
      status: _selectedStatus ?? Status.pendiente,
      estimatedHours: parsedHours.toDouble(),
      dueTime: widget.task?.dueTime,
      tags: widget.task?.tags ?? <String>[],
    );

    if (isEditing) {
      widget.onUpdateTask?.call(task);
    } else {
      widget.onAddTask?.call(task);
    }

    Navigator.of(context).pop();
  }

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

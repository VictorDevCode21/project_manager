import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:prolab_unimet/models/tasks_model.dart';
import 'package:prolab_unimet/widgets/add_task.dart';
import 'package:provider/provider.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskView();
}

class _TaskView extends State<TaskView> {
  final TextEditingController _taskcontroller = TextEditingController();
  String _selectedStatus = 'Prioridades';
  String _selectedAssignees = 'Responsables';
  late TaskController _taskController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskController = Provider.of<TaskController>(context);
    _taskController.setCurrentProject("32MZNpafyvefmnMnr6zv");
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // HEADER SECTION
                  Wrap(
                    spacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_back, color: Colors.grey),
                        label: Text(
                          'Volver',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          //backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Tareas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1b5bf5),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tablero para gestionar tareas de proyectos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // BUTTONS SECTION
                  Wrap(
                    spacing: 16,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddColumnDialog(context, taskController);
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Color(0xff38465a),
                        ),
                        label: const Text(
                          'Nueva Columna',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff38465a),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            224,
                            228,
                            231,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddTaskDialog(context, taskController);
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Nueva Tarea',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2d55fa),
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
                ],
              ),
              const SizedBox(height: 30),

              // FILTER SECTION
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;

                        if (isSmallScreen) {
                          return _buildMobileFilters();
                        } else {
                          return _buildDesktopFilters();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildBoard(taskController),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddColumnDialog(
    BuildContext context,
    TaskController taskController,
  ) {
    TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.grey.shade200;

    final List<Color> colorOptions = [
      Colors.grey,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.all(16),
              actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nueva Columna',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff253f8d),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la columna',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: En Espera',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 12),
                  const Text(
                    'Selecciona un color',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.blue, width: 2)
                                : Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                          ),
                          child: selectedColor == color
                              ? Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: nameController.text.trim().isEmpty
                      ? null
                      : () {
                          final newColumn = TaskColumn(
                            name: nameController.text.trim(),
                            color: selectedColor,
                          );
                          taskController.addColumn(newColumn);
                          Navigator.of(context).pop();
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Columna "${newColumn.name}" creada',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2d55fa),
                  ),
                  child: const Text(
                    'Crear Columna',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBoard(TaskController taskController) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _taskController.columns.map((column) {
          final columnTasks = _taskController.getTasksByColumn(column.name);

          return DragTarget<Map<String, dynamic>>(
            onAccept: (data) {
              _handleTaskDrop(data['task'], column.name);
            },
            builder: (context, candidateData, rejectData) {
              final isActive = candidateData.isNotEmpty;
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(color: Colors.blue, width: 2)
                      : Border.all(color: Colors.transparent),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          column.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: column.color,
                          ),
                        ),

                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteColumnDialog(
                                context,
                                column,
                                taskController,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar Columna'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (columnTasks.isEmpty)
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.blue.shade100
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isActive
                              ? Border.all(color: Colors.blueGrey, width: 1)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.move_to_inbox,
                              color: isActive
                                  ? Colors.blueGrey
                                  : Colors.grey[500],
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              isActive ? 'Soltar aquí' : 'Sin tareas',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.blueGrey
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: columnTasks.map((task) {
                          return _buildDraggableTaskCard(task, column);
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDraggableTaskCard(Task task, TaskColumn column) {
    return Draggable<Map<String, dynamic>>(
      data: {'task': task, 'sourceColumn': column.name},
      feedback: Material(
        elevation: 8,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildTaskContent(task),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCard(task, column),
      ),
      child: _buildTaskCard(task, column),
    );
  }

  Widget _buildTaskContent(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xff253f8d),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _showDeleteColumnDialog(
    BuildContext context,
    TaskColumn column,
    TaskController taskController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Columna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff253f8d),
          ),
        ),
        content: Text(
          '¿Seguro de que quieres eliminar la columna "${column.name}"?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              taskController.removeColumn(column);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Columna "${column.name}" eliminada'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskController taskController) {
    //final projectId = taskController.currentProjectId ?? 'proyecto-temporal';
    showDialog(
      context: context,
      builder: (context) => AddTask(
        columns: _taskController.columns,
        projectId: _taskController.currentProjectId!,
        //projectId: taskController.currentProjectId ?? 'proyecto-temporal',
        onAddTask: (newTask) async {
          try {
            await _taskController.addTask(newTask);
            Navigator.of(context).pop();
            print('✅ Diálogo cerrado exitosamente');
          } catch (e) {
            print('❌ Error en addTask: $e');
          }
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task, TaskColumn column) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xff253f8d),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (task.description.isNotEmpty)
            Text(
              task.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Asignado
              Text(
                task.assignee,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Prioridad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getPriorityText(task.priority),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTaskDrop(Task task, String targetColumnName) async {
    final statusMap = {
      'Pendiente': Status.pendiente,
      'En Progreso': Status.enProgreso,
      'En Revisión': Status.enRevision,
      'Completado': Status.completado,
    };

    final newStatus = statusMap[targetColumnName];
    if (newStatus != null && task.status != newStatus) {
      print('🎯 Moviendo tarea "${task.title}" de ${task.status} a $newStatus');
      print('🔄 Moviendo tarea "${task.title}" a $targetColumnName');
      try {
        await _taskController.updateTaskStatus(task.id, newStatus);
        print('✅ Tarea movida exitosamente a $targetColumnName');
      } catch (e) {
        print('❌ Error moviendo tarea: $e');
      }
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.alta:
        return Colors.red;
      case Priority.media:
        return Colors.orange;
      case Priority.baja:
        return Colors.green;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.alta:
        return 'ALTA';
      case Priority.media:
        return 'MEDIA';
      case Priority.baja:
        return 'BAJA';
    }
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Search field
        Expanded(
          child: TextField(
            controller: _taskcontroller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar por nombre de proyecto o cliente...',
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
          items: [
            'Prioridades',
            'Alta',
            'Media',
            'Baja',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {
            setState(() => _selectedStatus = value!);
          },
        ),
        const SizedBox(width: 16),

        // Type filter
        DropdownButton<String>(
          value: _selectedAssignees,
          items: [
            'Responsables',
            'Alta',
            'Media',
            'Baja',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {
            setState(() => _selectedAssignees = value!);
          },
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _taskcontroller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar proyectos...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filtros en fila para móvil
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true, // Importante para móvil
                items: ['Prioridades', 'Alta', 'Media', 'Baja']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedAssignees,
                isExpanded: true, // Importante para móvil
                items: ['Responsables', 'Alta', 'Media', 'Baja']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedAssignees = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

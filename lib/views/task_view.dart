import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:prolab_unimet/models/tasks_model.dart';
import 'package:prolab_unimet/views/tasks/add_task_dialog.dart';
import 'package:prolab_unimet/views/tasks/task_details_dialog.dart';
import 'package:provider/provider.dart';

class TaskView extends StatefulWidget {
  final String? projectId;

  const TaskView({super.key, this.projectId});

  @override
  State<TaskView> createState() => _TaskView();
}

class _TaskView extends State<TaskView> {
  final TextEditingController _taskcontroller = TextEditingController();
  String _selectedStatus = 'Prioridades';
  String _selectedAssignees = 'Responsables';
  late TaskController _taskController;
  bool _isInitialized = false;

  //AVOID REPEATED CALLS
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      _taskController = Provider.of<TaskController>(context);

      _taskController.loadAvailableProjects().then((_) {
        if (_taskController.availableProjects.isNotEmpty) {
          final firstProjectId =
              _taskController.availableProjects.first['id'] as String;
          _taskController.setCurrentProject(firstProjectId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //BUTTON "VOLVER" AND TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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
                    ],
                  ),
                ),
                //VERIFICATION PROJECTS EMPTY
                if (taskController.availableProjects.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //BUTTONS
                      Wrap(
                        spacing: 16,
                        alignment: WrapAlignment.end,
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

                      SizedBox(height: 12),
                      Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        //DROPDOWN WITH PROJECTS
                        child: IntrinsicWidth(
                          //adjust size
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 16,
                                color: Color(0xff253f8d),
                              ),
                              SizedBox(width: 8),
                              Container(
                                constraints: BoxConstraints(
                                  minWidth: 120,
                                  maxWidth: 200,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _taskController.currentProjectId,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xff253f8d),
                                      size: 18,
                                    ),
                                    iconSize: 18,
                                    dropdownColor: Colors.white,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff253f8d),
                                    ),
                                    items: _taskController.availableProjects
                                        .map((project) {
                                          return DropdownMenuItem<String>(
                                            value: project['id'],
                                            child: Text(
                                              project['name'] ?? 'Sin nombre',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff253f8d),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        })
                                        .toList(),
                                    onChanged: (projectId) {
                                      if (projectId != null) {
                                        _taskController.setCurrentProject(
                                          projectId,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            //===========TASK BOARD=========================
            if (taskController.availableProjects.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 50, color: Colors.grey),
                      SizedBox(height: 20),
                      Text('No tienes acceso a ningún proyecto'),
                      SizedBox(height: 10),
                      Text('Contacta al administrador'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      //======FILTER==============
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
                                final isSmallScreen =
                                    constraints.maxWidth < 600;
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
                      //======KABAN BOARD=========
                      _buildBoard(taskController),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //KABAN BOARD WITH EVERYTHING
  Widget _buildBoard(TaskController taskController) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _taskController.columns.map((column) {
          //tasks that belong to a specific column
          final columnTasks = _taskController.getTasksByColumn(column.name);

          return DragTarget<Map<String, dynamic>>(
            //drag and drop
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
                      ? Border.all(color: Colors.blue.shade500, width: 2)
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
                        //OPTIONS MENU
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

                    //COLUMN CONTENT
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

  //DRAGGABLE TASK CARD
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

  //SIMPLIFIED TASK CONTENT
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

  //CONSTRUCT THE COMPLETE TASK CARD
  Widget _buildTaskCard(Task task, TaskColumn column) {
    return GestureDetector(
      onTap: () {
        _showTaskDetailsDialog(context, task);
      },
      child: Container(
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
        child: Row(
          children: [
            Icon(Icons.drag_handle, color: Colors.grey[400], size: 16),
            SizedBox(width: 8),

            Expanded(
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
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.assignee,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
            ),
          ],
        ),
      ),
    );
  }

  //ADD TASKS
  void _showAddTaskDialog(BuildContext context, TaskController taskController) {
    final projectType =
        _taskController.currentProject?.consultingType ?? 'Proyecto';
    //final projectName = _taskController.currentProject?.name ?? 'Sin nombre';

    showDialog(
      context: context,
      builder: (context) => AddTask(
        columns: _taskController.columns,
        projectId: _taskController.currentProjectId!,
        //projectId: taskController.currentProjectId ?? 'proyecto-temporal',
        projectType: projectType,
        onAddTask: (newTask) async {
          try {
            await _taskController.addTask(newTask);
            Navigator.of(context).pop();
          } catch (e) {}
        },
      ),
    );
  }

  //SHOW DETAILS FOR EDITING TASKS
  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(
        task: task,
        onEditPressed: () {
          Navigator.of(context).pop();
          _showEditTaskDialog(context, task);
        },
        onDeletePressed: () {
          Navigator.of(context).pop();
          _showDeleteTaskConfirmation(context, task);
        },
      ),
    );
  }

  //EDIT TASK DIALOG
  void _showEditTaskDialog(BuildContext context, Task task) {
    final scaffoldContext = context;
    final projectType =
        _taskController.currentProject?.consultingType ?? 'Proyecto';
    //final projectName = _taskController.currentProject?.name ?? 'Sin nombre';
    showDialog(
      context: context,
      builder: (context) => AddTask(
        task: task,
        columns: _taskController.columns,
        projectId: _taskController.currentProjectId!,
        projectType: projectType,
        onUpdateTask: (updatedTask) async {
          try {
            await _taskController.updateTask(updatedTask);
            Navigator.of(context).pop();

            if (scaffoldContext.mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Tarea "${updatedTask.title}" actualizada'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (scaffoldContext.mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Error actualizando tarea: $e'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  //WARNING: DELETE TASK
  void _showDeleteTaskConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Tarea',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff253f8d),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar la tarea "${task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _taskController.deleteTask(task.id);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tarea "${task.title}" eliminada'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error eliminando tarea: $e'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
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

  //WARNING: DELETE COLUMN
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

  //DRAG AND DROP
  void _handleTaskDrop(Task task, String targetColumnName) async {
    final statusMap = {
      'Pendiente': Status.pendiente,
      'En Progreso': Status.enProgreso,
      'En Revisión': Status.enRevision,
      'Completado': Status.completado,
    };

    final newStatus = statusMap[targetColumnName];
    if (newStatus != null && task.status != newStatus) {
      try {
        await _taskController.updateTaskStatus(task.id, newStatus);
      } catch (e) {
        //
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

  //FILTER DESKTOP
  Widget _buildDesktopFilters() {
    return Row(
      children: [
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

  //FILTER MOBILE
  Widget _buildMobileFilters() {
    return Column(
      children: [
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

        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
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
                isExpanded: true,
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

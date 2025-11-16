import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/task_controller.dart';
import 'package:prolab_unimet/models/tasks_model.dart';
import 'package:prolab_unimet/views/tasks/add_task_dialog.dart';
import 'package:prolab_unimet/views/tasks/task_details_dialog.dart';
import 'package:provider/provider.dart';

/// Main view that renders the tasks board (Kanban) and project selector.
class TaskView extends StatefulWidget {
  final String? projectId;

  const TaskView({super.key, this.projectId});

  @override
  State<TaskView> createState() => _TaskView();
}

class _TaskView extends State<TaskView> {
  final TextEditingController _taskcontroller = TextEditingController();
  String _selectedStatus = 'Prioridades';
  late TaskController _taskController;
  bool _isInitialized = false;

  /// Horizontal scroll controller for the Kanban board.
  late final ScrollController _horizontalBoardController;

  @override
  void initState() {
    super.initState();
    _horizontalBoardController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      _taskController = Provider.of<TaskController>(context);

      _taskController.loadAvailableProjects().then((_) {
        if (_taskController.availableProjects.isNotEmpty) {
          final String firstProjectId =
              _taskController.availableProjects.first['id'] as String;
          _taskController.setCurrentProject(firstProjectId);
        }
      });
    }
  }

  @override
  void dispose() {
    _horizontalBoardController.dispose();
    _taskcontroller.dispose();
    super.dispose();
  }

  /// Maps the selected status label to a Priority enum, or null for "no filter".
  Priority? _getSelectedPriorityFilter() {
    switch (_selectedStatus) {
      case 'Alta':
        return Priority.high;
      case 'Media':
        return Priority.medium;
      case 'Baja':
        return Priority.low;
      case 'Prioridades':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Provider.of<TaskController>(context);

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER WITH BACK BUTTON, TITLE AND PROJECT SELECTOR =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 20,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
                // Actions and project selector (only if there are accessible projects)
                if (taskController.availableProjects.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Action buttons
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
                      const SizedBox(height: 12),
                      // Project selector
                      Builder(
                        builder: (BuildContext context) {
                          final double screenWidth = MediaQuery.of(
                            context,
                          ).size.width;

                          final double dropdownWidth = (screenWidth * 0.20)
                              .clamp(140.0, 260.0);

                          return Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  size: 16,
                                  color: Color(0xff253f8d),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: dropdownWidth,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _taskController.currentProjectId,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xff253f8d),
                                        size: 18,
                                      ),
                                      iconSize: 18,
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff253f8d),
                                      ),
                                      items: _taskController.availableProjects
                                          .map((Map<String, dynamic> project) {
                                            return DropdownMenuItem<String>(
                                              value: project['id'] as String?,
                                              child: Text(
                                                project['name'] as String? ??
                                                    'Sin nombre',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff253f8d),
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (String? projectId) {
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
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
            // ===== MAIN CONTENT =====
            if (taskController.availableProjects.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                      const SizedBox(height: 30),
                      // Filters card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: <BoxShadow>[
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
                              builder:
                                  (
                                    BuildContext context,
                                    BoxConstraints constraints,
                                  ) {
                                    final bool isSmallScreen =
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
                      const SizedBox(height: 40),
                      // Kanban board with horizontal scrollbar
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

  /// Resolves an assigneeId into a human readable name using project members list.
  String _resolveAssigneeName(String assigneeId) {
    final List<Map<String, String>> members = _taskController.projectMembers;

    if (assigneeId.isEmpty) {
      return 'Sin asignar';
    }

    try {
      final Map<String, String> match = members.firstWhere(
        (Map<String, String> m) => m['id'] == assigneeId,
      );
      return match['name'] ?? 'Sin asignar';
    } catch (_) {
      return 'Usuario desconocido';
    }
  }

  /// Builds the horizontal Kanban board with drag & drop support.
  /// Applies search by task title and priority filter.
  Widget _buildBoard(TaskController taskController) {
    final String query = _taskcontroller.text.trim().toLowerCase();
    final Priority? selectedPriority = _getSelectedPriorityFilter();

    return Scrollbar(
      controller: _horizontalBoardController,
      thumbVisibility: true,
      trackVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalBoardController,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: taskController.columns.map((TaskColumn column) {
            // Base tasks for this column (by status)
            List<Task> columnTasks = taskController.getTasksByColumn(
              column.name,
            );

            // Filter by search text (title)
            if (query.isNotEmpty) {
              columnTasks = columnTasks.where((Task task) {
                return task.title.toLowerCase().contains(query);
              }).toList();
            }

            // Filter by priority if any selected
            if (selectedPriority != null) {
              columnTasks = columnTasks
                  .where((Task task) => task.priority == selectedPriority)
                  .toList();
            }

            return DragTarget<Map<String, dynamic>>(
              onAcceptWithDetails:
                  (DragTargetDetails<Map<String, dynamic>> details) {
                    final Map<String, dynamic> data = details.data;
                    _handleTaskDrop(data['task'] as Task, column.name);
                  },
              builder:
                  (
                    BuildContext context,
                    List<Map<String, dynamic>?> candidateData,
                    List<dynamic> rejectData,
                  ) {
                    final bool isActive = candidateData.isNotEmpty;
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
                        boxShadow: <BoxShadow>[
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
                          // Column header and menu
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
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[600],
                                ),
                                onSelected: (String value) {
                                  if (value == 'delete') {
                                    _showDeleteColumnDialog(
                                      context,
                                      column,
                                      taskController,
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuItem<String>>[
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
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
                          // Column content
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
                                    ? Border.all(
                                        color: Colors.blueGrey,
                                        width: 1,
                                      )
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
                                  const SizedBox(height: 4),
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
                              children: columnTasks.map((Task task) {
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
      ),
    );
  }

  /// Wraps a task card in a Draggable so it can be moved between columns.
  Widget _buildDraggableTaskCard(Task task, TaskColumn column) {
    return Draggable<Map<String, dynamic>>(
      data: <String, dynamic>{'task': task, 'sourceColumn': column.name},
      feedback: Material(
        elevation: 8,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
            boxShadow: <BoxShadow>[
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

  /// Compact task content used in drag feedback.
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

  /// Full task card rendered inside each column.
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
          boxShadow: <BoxShadow>[
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
            const SizedBox(width: 8),
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
                        _resolveAssigneeName(task.assignee),
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

  /// Opens dialog to create a new task for the current project.
  void _showAddTaskDialog(BuildContext context, TaskController taskController) {
    final String projectType =
        _taskController.currentProjectData?['consultingType'] as String? ??
        'Proyecto';

    final String projectName =
        _taskController.currentProjectData?['name'] as String? ?? 'Proyecto';

    showDialog(
      context: context,
      builder: (BuildContext context) => AddTask(
        columns: _taskController.columns,
        projectId: _taskController.currentProjectId!,
        projectType: projectType,
        projectName: projectName,
        projectMembers: _taskController.projectMembers,
        onAddTask: (Task newTask) async {
          try {
            await _taskController.addTask(newTask);
          } catch (_) {
            // Errors can be handled with another snackbar if needed.
          }
        },
      ),
    );
  }

  /// Opens dialog with task details (view / edit / delete).
  void _showTaskDetailsDialog(BuildContext context, Task task) {
    final String assigneeName = _resolveAssigneeName(task.assignee);

    // Read project name from current project data
    final String projectName =
        _taskController.currentProjectData?['name'] as String? ?? 'Proyecto';

    showDialog(
      context: context,
      builder: (BuildContext context) => TaskDetailsDialog(
        task: task,
        assigneeDisplayName: assigneeName,
        projectName: projectName,
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

  /// Opens dialog to edit an existing task.
  void _showEditTaskDialog(BuildContext context, Task task) {
    final BuildContext scaffoldContext = context;

    final String projectType =
        _taskController.currentProjectData?['consultingType'] as String? ??
        'Tipo Desconocido';

    final String projectName =
        _taskController.currentProjectData?['name'] as String? ?? 'Proyecto';

    showDialog(
      context: context,
      builder: (BuildContext context) => AddTask(
        task: task,
        columns: _taskController.columns,
        projectId: _taskController.currentProjectId!,
        projectType: projectType,
        projectName: projectName,
        projectMembers: _taskController.projectMembers,
        onUpdateTask: (Task updatedTask) async {
          try {
            await _taskController.updateTask(updatedTask);

            if (scaffoldContext.mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Tarea "${updatedTask.title}" actualizada'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (scaffoldContext.mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Error actualizando tarea: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  /// Shows confirmation dialog before deleting a task.
  void _showDeleteTaskConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
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
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _taskController.deleteTask(task.id);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tarea "${task.title}" eliminada'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error eliminando tarea: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens dialog to create a new custom column for the board.
  void _showAddColumnDialog(
    BuildContext context,
    TaskController taskController,
  ) {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.grey.shade200;

    final List<Color> colorOptions = <Color>[
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setStateDialog,
              ) {
                return AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  actionsPadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nueva Columna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff253f8d),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      const Text(
                        'Selecciona un color',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: colorOptions.map((Color color) {
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
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
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
                              final TaskColumn newColumn = TaskColumn(
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

  /// Shows confirmation dialog before deleting a column.
  void _showDeleteColumnDialog(
    BuildContext context,
    TaskColumn column,
    TaskController taskController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Eliminar Columna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff253f8d),
          ),
        ),
        content: Text(
          '¿Seguro de que quieres eliminar la columna "${column.name}"?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles drag & drop status changes between board columns.
  void _handleTaskDrop(Task task, String targetColumnName) async {
    final Map<String, Status> statusMap = <String, Status>{
      'Pendiente': Status.pendiente,
      'En Progreso': Status.enProgreso,
      'En Revisión': Status.enRevision,
      'Completado': Status.completado,
    };

    final Status? newStatus = statusMap[targetColumnName];
    if (newStatus != null && task.status != newStatus) {
      try {
        await _taskController.updateTaskStatus(task.id, newStatus);
      } catch (_) {
        // Error can be handled with snackbar if needed.
      }
    }
  }

  /// Returns color used in priority pill for each priority level.
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  /// Returns Spanish label for each priority to show in the pill.
  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'ALTA';
      case Priority.medium:
        return 'MEDIA';
      case Priority.low:
        return 'BAJA';
    }
  }

  /// Builds desktop layout filters row.
  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskcontroller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar por nombre de tarea...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (String value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedStatus,
          items: <String>['Prioridades', 'Alta', 'Media', 'Baja']
              .map(
                (String e) =>
                    DropdownMenuItem<String>(value: e, child: Text(e)),
              )
              .toList(),
          onChanged: (String? value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Builds mobile layout filters column.
  Widget _buildMobileFilters() {
    return Column(
      children: [
        TextField(
          controller: _taskcontroller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar por nombre de tarea...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (String value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: <String>['Prioridades', 'Alta', 'Media', 'Baja']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() => _selectedStatus = value);
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}

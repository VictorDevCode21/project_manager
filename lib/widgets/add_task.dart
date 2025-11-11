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
  // final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _descriptionController = TextEditingController();
  // final TextEditingController _hoursController = TextEditingController();
  // String _selectedtProjectType = 'Calidad ambiental';
  // String _selectedAssignee = 'Maria';
  // Priority _selectedPriority = Priority.media;
  // Status _selectedStatus = Status.pendiente;
  // TaskColumn? _selectedColumn;

  // final List<String> _projectTypes = [
  //   'Calidad Ambiental',
  //   'Construcción',
  //   'Tecnología',
  // ];

  // final List<String> _assignees = ['Maria', 'Juan', 'Alcachofa'];

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.columns.isNotEmpty) {
  //     _selectedColumn = widget.columns.first;
  //   }
  // }

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
              //controller: ,
              decoration: InputDecoration(
                labelText: 'Título de la tarea *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12),

            TextField(
              //controller: ,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                //Es un dropdown, pero para probar valores se usara un textfield
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Proyecto',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(width: 20),

                //Tmb es ddown
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Asignado',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

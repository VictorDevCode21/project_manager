import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prolab_unimet/models/tasks_model.dart';

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final VoidCallback onEditPressed;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: EdgeInsets.all(20),
    );
  }
}

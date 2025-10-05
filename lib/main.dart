import 'package:flutter/material.dart';
import 'package:web_project_manager/view/register_view.dart';

void main() {
  runApp(const ProjectManagerWeb());
}

class ProjectManagerWeb extends StatelessWidget {
  const ProjectManagerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterView(),
    );
  }
}

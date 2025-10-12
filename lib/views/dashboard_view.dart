import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Coordinador'),
        backgroundColor: const Color(0xff253f8d),
      ),
      body: const Center(
        child: Text(
          'Bienvenido al Dashboard 👋',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskView();
}

class _TaskView extends State<TaskView> {
  final TextEditingController _taskcontroller = TextEditingController();
  String _selectedStatus = 'Todos los estados';
  String _selectedAssignees = 'Todos los tipos';

  @override
  Widget build(BuildContext context) {
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
                  Wrap(
                    spacing: 16,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          //crear
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
                          //crear tareas
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
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          child: TextField(
                            controller: _taskcontroller,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText:
                                  'Buscar por nombre de proyecto o cliente...',
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
                          items:
                              [
                                    'Todos los estados',
                                    'En Progreso',
                                    'Planificación',
                                    'Completado',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value!);
                          },
                        ),
                        const SizedBox(width: 16),

                        // Type filter
                        DropdownButton<String>(
                          value: _selectedAssignees,
                          items:
                              [
                                    'Todos los tipos',
                                    'Calidad Ambiental',
                                    'Construcción',
                                    'Tecnología',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAssignees = value!);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

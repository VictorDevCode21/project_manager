import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/resources_controller.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ResourcesBar(),
          SizedBox(height: 30),
          Stats(),
          SizedBox(height: 30),
          SearchBar1(),
          SizedBox(height: 15),
          Selector1(),
        ],
      ),
    );
  }
}

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screen3()),
                );
              },
              icon: Icon(Icons.arrow_back, color: Colors.black),
              label: Text(
                'Volver',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Recursos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text('Administrar recursos humanos y materiales'),
              ],
            ),
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignProject()),
                );
              },
              icon: Icon(Icons.person_add, color: Colors.black),
              label: Text(
                'Asignar recursos',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            SizedBox(width: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screen3()),
                );
              },
              icon: Icon(Icons.add_box, color: Colors.white),
              label: Text(
                'Agregar recursos',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
          shadowColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(248, 221, 217, 217),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal disponible'),
                SizedBox(height: 30),
                Text(
                  'X',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('de Y total'),
              ],
            ),
          ),
        ),

        Card(
          shadowColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(248, 221, 217, 217),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Equipos disponibles'),
                SizedBox(height: 30),
                Text(
                  'X',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.indigoAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('de Y total'),
              ],
            ),
          ),
        ),

        Card(
          shadowColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(248, 221, 217, 217),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Utilización promedio'),
                SizedBox(height: 30),
                Text(
                  'X%',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('de Y total'),
              ],
            ),
          ),
        ),

        Card(
          shadowColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(248, 221, 217, 217),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('En mantenimiento'),
                SizedBox(height: 40),
                Text(
                  'X',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('de Y total'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SearchBar1 extends StatefulWidget {
  const SearchBar1({super.key});

  @override
  State<SearchBar1> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar1> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Todos los estados';
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      child: Container(
        width: 1100,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color.fromARGB(248, 221, 217, 217)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros y Búsqueda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: SearchController(), //ESTO CAMBIALO
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre de recurso',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.search),
                  color: Colors.indigo,
                ),
                const SizedBox(width: 16),
                // Status filter
                DropdownButton<String>(
                  value: _selectedStatus,
                  items:
                      [
                            'Todos los estados',
                            'Disponible',
                            'Parcialmente Disponible',
                            'Mantenimiento',
                            'Ocupado',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    ResourcesController controller = ResourcesController();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text(
                  'Volver al menú',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Creación de recursos humanos',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: 15),

          Text('Nombre'),
          CustomTextField(
            labelText: 'nombre',
            controller: controller.nameController,
            validator: controller.validateName,
          ),
          Text('Estado del recurso'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Estado del recurso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
              DropdownMenuItem(
                value: 'Parcialmente Disponible',
                child: Text('Parcialmente Disponible'),
              ),
              DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
            ],
            initialValue: controller.stateC,
            onChanged: (value) => setState(() => controller.stateC = value),
            validator: (_) => controller.validateState(),
          ),
          Text('Laboratorio'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Laboratorio',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'Laboratorio de Suelos',
                child: Text('Laboratorio de Suelos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Materiales y ensayos',
                child: Text('Laboratorio de Materiales y ensayos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Calidad Ambiental',
                child: Text('Laboratorio de Calidad Ambiental'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Vibraciones',
                child: Text('Laboratorio de Vibraciones'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Ciencia de los Materiales',
                child: Text('Laboratorio de Ciencia de los Materiales'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Mecanica y Fluidos',
                child: Text('Laboratorio de Mecanica y Fluidos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de impresion 3D',
                child: Text('Laboratorio de impresion 3D'),
              ),
            ],
            initialValue: controller.labC,
            onChanged: (value) => setState(() => controller.labC = value),
            validator: (_) => controller.validateLab(),
          ), //Puedes poner el q sea
          Text('Tarifa horaria'),
          CustomTextField(
            labelText: 'tarifa',
            controller: controller.tarifController,
            validator: controller.validateTarif,
          ),
          Text('Uso total'),
          CustomTextField(
            labelText: 'uso',
            controller: controller.totalUsage,
            validator: controller.validateTarif,
          ), //Se valida practicamente lo mismo que en tarifa
          Text('Correo'),
          CustomTextField(
            labelText: 'correo',
            controller: controller.email,
            validator: controller.validateEmail,
          ),
          Text('Habilidades'),
          CustomTextField(
            labelText: 'habilidades',
            maxLines: 4,
            controller: controller.habilities,
            validator: controller.validateHabilities,
          ),
          Text('Departamento'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Selecciona un departamento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'Construccion y Desarrollo Sustentable',
                child: Text('Construccion y Desarrollo Sustentable'),
              ),
              DropdownMenuItem(
                value: 'Energia y Automatizacion',
                child: Text('Energia y Automatizacion'),
              ),
              DropdownMenuItem(
                value: 'Produccion Industrial',
                child: Text('Produccion Industrial'),
              ),
              DropdownMenuItem(
                value: 'Gestion de Proyectos y Sistemas',
                child: Text('Gestion de Proyectos y Sistemas'),
              ),
            ],

            initialValue: controller.departmentC,
            onChanged: (value) =>
                setState(() => controller.departmentC = value),
            validator: (_) => controller.validateDepartment(),
          ),
          TextButton(
            onPressed: () {
              try {
                controller.createHResource(context);
              } catch (e) {}
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    ResourcesController controller = ResourcesController();
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text(
                  'Volver al menú',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Creación de recursos materiales',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: 15),
          const Text('Nombre'),
          CustomTextField(
            labelText: 'nombre',
            controller: controller.nameController,
            validator: controller.validateName,
          ),
          const Text('Estado del recurso'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Estado del recurso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
              DropdownMenuItem(
                value: 'Parcialmente Disponible',
                child: Text('Parcialmente Disponible'),
              ),
              DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
              DropdownMenuItem(
                value: 'Mantenimiento',
                child: Text('Mantenimiento'),
              ),
            ],
            initialValue: controller.stateC,
            onChanged: (value) => setState(() => controller.stateC = value),
            validator: (_) => controller.validateState(),
          ),
          const Text('Laboratorio'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Laboratorio',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'Laboratorio de Suelos',
                child: Text('Laboratorio de Suelos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Materiales y ensayos',
                child: Text('Laboratorio de Materiales y ensayos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Calidad Ambiental',
                child: Text('Laboratorio de Calidad Ambiental'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Vibraciones',
                child: Text('Laboratorio de Vibraciones'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Ciencia de los Materiales',
                child: Text('Laboratorio de Ciencia de los Materiales'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de Mecanica y Fluidos',
                child: Text('Laboratorio de Mecanica y Fluidos'),
              ),
              DropdownMenuItem(
                value: 'Laboratorio de impresion 3D',
                child: Text('Laboratorio de impresion 3D'),
              ),
            ],
            initialValue: controller.labC,
            onChanged: (value) => setState(() => controller.labC = value),
            validator: (_) => controller.validateLab(),
          ),
          Text('Tarifa horaria'),
          CustomTextField(
            labelText: 'tarifa',
            controller: controller.tarifController,
            validator: controller.validateTarif,
          ),
          const Text('Condición'),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Condición del recurso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'Excelente', child: Text('Excelente')),
              DropdownMenuItem(value: 'Buena', child: Text('Buena')),
              DropdownMenuItem(value: 'Regular', child: Text('Regular')),
              DropdownMenuItem(value: 'Mala', child: Text('Mala')),
            ],
            initialValue: controller.conditionC,
            onChanged: (value) => setState(() => controller.conditionC = value),
            validator: (_) => controller.validateCondition(),
          ),
          const Text('Ultimo mantenimiento'),
          TextFormField(
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                initialDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() => controller.lastDate = pickedDate);
              }
            },
            controller: TextEditingController(
              text: controller.lastDate == null
                  ? ''
                  : '${controller.lastDate!.day}/${controller.lastDate!.month}/${controller.lastDate!.year}',
            ),
            validator: (_) => controller.validateLastDate(),
            decoration: InputDecoration(
              hintText: 'dd/mm/yyyy',
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Text('Proximo mantenimiento'),
          TextFormField(
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2025),
                initialDate: DateTime.now(),
                lastDate: DateTime(2035),
              );
              if (pickedDate != null) {
                setState(() => controller.nextDate = pickedDate);
              }
            },
            controller: TextEditingController(
              text: controller.nextDate == null
                  ? ''
                  : '${controller.nextDate!.day}/${controller.nextDate!.month}/${controller.nextDate!.year}',
            ),
            validator: (_) => controller.validateNextDate(),
            decoration: InputDecoration(
              hintText: 'dd/mm/yyyy',
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Text('Especificaciones'),
          CustomTextField(
            labelText: 'especificaciones',
            controller: controller.specs,
          ),
          TextButton(
            onPressed: () {
              try {
                controller.createMResource(context);
              } catch (e) {}
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class Selector1 extends StatefulWidget {
  const Selector1({super.key});

  @override
  State<Selector1> createState() => _Selector1State();
}

class _Selector1State extends State<Selector1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: null,
              icon: Icon(Icons.person, color: Colors.black),
              label: Text(
                'Recursos Humanos',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            TextButton.icon(
              onPressed: null,
              icon: Icon(Icons.cable, color: Colors.black),
              label: Text(
                'Recursos Materiales',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
        Wrap(
          children: [
            _buildHResourceCard(
              name: 'Ricardo Fernandez',
              lab: 'Sistemas',
              state: 'Mantenimiento',
              projects: ['hola', 'hola2'],
              progress: 0.54,
              tarif: '\$130',
              email: 'r.fernandez@correo.unimet.edu.ve',
              habilities: 'habilities',
            ),
            _buildMResourceCard(
              name: 'Telescopio',
              lab: 'Calidad ambiental',
              state: 'Disponible',
              projects: ['hola', 'hola2'],
              tarif: '\$2630',
              condition: 'Excelente',
              lastDate: '19/12/2025',
              nextDate: '20/12/2025',
              specs: 'Hil',
            ),
            _buildMResourceCard(
              name: 'Telescopio',
              lab: 'Calidad ambiental',
              state: 'Disponible',
              projects: ['hola', 'hola2'],
              tarif: '\$2630',
              condition: 'Excelente',
              lastDate: '19/12/2025',
              nextDate: '20/12/2025',
              specs: 'Hil',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHResourceCard({
    required String name,
    required String lab,
    required String state,
    required List<String> projects,
    required double progress,
    required String tarif,
    required String email,
    required String habilities,
  }) {
    return Card(
      shadowColor: Colors.black,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Title and description
            Row(
              children: [
                Icon(Icons.person, color: Colors.indigo, size: 30),
                Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xff253f8d),
                      ),
                    ),
                    Text(
                      lab,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              'Proyectos',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            Wrap(
              spacing: 6,
              children: projects.map((t) => _buildTag(t)).toList(),
            ),
            const SizedBox(height: 12),

            _buildTag(state),

            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progreso', style: TextStyle(color: Colors.black54)),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xff253f8d),
              ),
            ),
            const SizedBox(height: 16),

            // Info section
            _buildInfoRow('Tarifa por hora:', tarif),
            _buildInfoRow('Contacto:', email),
            _buildInfoRow('Habilidades:', habilities),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Asignar proyecto'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff253f8d),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMResourceCard({
    required String name,
    required String lab,
    required String state,
    required List<String> projects,
    required String tarif,
    required String condition,
    required String lastDate,
    required String nextDate,
    required String specs,
  }) {
    return Card(
      shadowColor: Colors.black,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(248, 221, 217, 217)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xff253f8d),
              ),
            ),
            Text(
              lab,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),

            const SizedBox(height: 10),

            Text(
              'Proyecto actual',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            Wrap(
              spacing: 6,
              children: projects.map((t) => _buildTag(t)).toList(),
            ),
            const SizedBox(height: 12),

            Row(children: [_buildTag(state), _buildTag(condition)]),
            const SizedBox(height: 16),

            // Info section
            _buildInfoRow('Tarifa por hora:', tarif),
            _buildInfoRow('Ultimo mantenimiento:', lastDate),
            _buildInfoRow('Proximo mantenimiento:', nextDate),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Asignar proyecto'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff253f8d),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for rendering project tags.
  Widget _buildTag(String label) {
    Color bg;
    Color txt;
    switch (label) {
      case 'Excelente':
        bg = const Color(0xffe3f2fd);
        txt = const Color.fromARGB(255, 107, 135, 187);
        break;
      case 'Bueno':
        bg = const Color(0xffe8f5e9);
        txt = const Color.fromARGB(255, 52, 173, 62);
        break;
      case 'Regular':
        bg = const Color(0xfffff3e0);
        txt = const Color.fromARGB(255, 230, 140, 66);
        break;
      case 'Malo':
        bg = const Color(0xffffebee);
        txt = const Color.fromARGB(255, 231, 69, 69);
        break;
      case 'Disponible':
        bg = const Color(0xffe3f2fd);
        txt = const Color.fromARGB(255, 52, 173, 62);
        break;
      case 'Parcialmente disponible':
        bg = const Color(0xffe8f5e9);
        txt = const Color.fromARGB(255, 52, 173, 62);
        break;
      case 'Mantenimiento':
        bg = const Color(0xfffff3e0);
        txt = const Color.fromARGB(255, 230, 140, 66);
        break;
      case 'Ocupado':
        bg = const Color(0xffffebee);
        txt = const Color.fromARGB(255, 231, 69, 69);
        break;
      default:
        bg = Colors.grey.shade200;
        txt = const Color.fromRGBO(0, 0, 0, 1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: txt)),
    );
  }

  /// Helper for displaying labeled rows.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AssignProject extends StatelessWidget {
  const AssignProject({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text(
                  'Volver al menú',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asignar Recursos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Text('Asignar personal y equipos a proyectos'),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de Asignación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text('Seleccionar proyecto y configurar la asignación'),
                SizedBox(height: 10),
                Wrap(
                  children: [
                    Column(
                      children: [
                        Text('Proyecto'),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Seleccionar proyecto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            //AUN NO HAY NADA
                          ],
                          onChanged: null,
                          /*initialValue: controller.stateC,
            onChanged: (value) => setState(() => controller.stateC = value),
            validator: (_) => controller.validateState(),*/
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Prioridad'),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Seleccionar prioridad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Alta',
                              child: Text('Alta'),
                            ),
                            DropdownMenuItem(
                              value: 'Media',
                              child: Text('Media'),
                            ),
                            DropdownMenuItem(
                              value: 'Baja',
                              child: Text('Baja'),
                            ),
                          ],
                          onChanged: null,
                          /*initialValue: controller.stateC,
            onChanged: (value) => setState(() => controller.stateC = value),
            validator: (_) => controller.validateState(),*/
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Descripción de la asignación'),
                        TextField(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

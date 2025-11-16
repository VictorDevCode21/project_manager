import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:prolab_unimet/controllers/resources_controller.dart';
import 'package:prolab_unimet/models/resources_model.dart';
import 'package:prolab_unimet/views/components/resources/assign_resource.dialog.dart';

final ResourcesController _controller = ResourcesController();

class AssignProject extends StatefulWidget {
  const AssignProject({super.key});

  @override
  State<AssignProject> createState() => _AssignProjectState();
}

class _AssignProjectState extends State<AssignProject> {
  ResourcesController controller = ResourcesController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Asignar Recursos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Asignar personal y equipos a proyectos',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de Asignación',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Seleccionar proyecto y configurar la asignación'),
                  const SizedBox(height: 7),

                  // Proyecto
                  const Text('Proyecto *'),
                  FutureBuilder<List<String>>(
                    future: controller.nombreProyectos(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'No se han cargado los datos',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: null,
                          items: const [],
                        );
                      }
                      List<String> nombres = snap.data!;
                      List<DropdownMenuItem<String>> items = nombres
                          .map<DropdownMenuItem<String>>((String nombre) {
                            return DropdownMenuItem<String>(
                              value: nombre,
                              child: Text(nombre),
                            );
                          })
                          .toList();

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar Proyecto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        initialValue: controller.proyecto,
                        items: items,
                        onChanged: (String? nuevovalor) {
                          setState(() {
                            controller.proyecto = nuevovalor;
                          });
                        },
                      );
                    },
                  ),

                  // Prioridad
                  const Text('Prioridad *'),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Condición del recurso',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    ],
                    initialValue: controller.priority,
                    onChanged: (value) =>
                        setState(() => controller.priority = value),
                    validator: (_) => controller.validatePriority(),
                  ),

                  // Recurso
                  const Text('Recurso *'),
                  FutureBuilder<List<String>>(
                    future: controller.nombreRecursos(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'No se han cargado los datos',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: null,
                          items: const [],
                        );
                      }

                      List<String> nombres = snap.data!;
                      List<DropdownMenuItem<String>> items = nombres
                          .map<DropdownMenuItem<String>>((String nombre) {
                            return DropdownMenuItem<String>(
                              value: nombre,
                              child: Text(nombre),
                            );
                          })
                          .toList();

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar Recurso',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        initialValue: controller.resource,
                        items: items,
                        onChanged: (String? nuevovalor) {
                          setState(() {
                            controller.resource = nuevovalor;
                          });
                        },
                      );
                    },
                  ),

                  // Descripción
                  const Text('Descripción de la asignación'),
                  CustomTextField(
                    hintText:
                        'Describe el proposito y alcance de esta asignación...',
                    controller: controller.descripcionassign,
                  ),

                  // Horas
                  const Text('Horas asignadas'),
                  CustomTextField(
                    hintText: 'Ejemplo: 8',
                    controller: controller.usage,
                    validator: controller.validateTarif,
                  ),
                ],
              ),
            ),
          ),

          // Botón enviar
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Asignando recurso...')),
                    );

                    if (controller.resource == null ||
                        controller.proyecto == null) {
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona un proyecto y un recurso antes de asignar.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await controller.assignProject(
                        controller.proyecto,
                        controller.resource,
                        controller.usage.text,
                        context,
                      );

                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Recurso asignado!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Reset de formulario a valores por defecto
                      setState(() {
                        _formKey.currentState!.reset();
                        controller.descripcionassign.clear();
                        controller.usage.clear();
                        controller.priority = null;
                        controller.proyecto = null;
                        controller.resource = null;
                      });
                    } catch (e) {
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('❌ Error al asignar recurso: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff253f8d),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Asignar a proyecto',
                    style: TextStyle(fontSize: 18),
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

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  final ResourcesController _controller = ResourcesController();

  @override
  void initState() {
    super.initState();
    _controller.fetchAndCalculateStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ResourcesBar(),
            const SizedBox(height: 30),
            ValueListenableBuilder<ResourceStats>(
              valueListenable: _controller.statsNotifier,
              builder: (context, stats, child) {
                return _buildStatsRow(stats);
              },
            ),
            const SizedBox(height: 30),
            SearchBar1(controller: _controller),
            const SizedBox(height: 15),
            Selector1(controller: _controller),
            const SizedBox(height: 20),
            ResourceList(controller: _controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ResourceStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          title: 'Personal Disponible',
          value: stats.availablePersonnel.toString(),
          total: 'de ${stats.totalPersonnel} total',
          color: Colors.green.shade600,
        ),
        _buildStatCard(
          title: 'Equipos Disponibles',
          value: stats.availableEquipment.toString(),
          total: 'de ${stats.totalEquipment} total',
          color: Colors.blue.shade600,
        ),
        _buildStatCard(
          title: 'Utilización Promedio',
          value: '${(stats.averageUtilization * 100).toStringAsFixed(0)}%',
          total: 'capacidad utilizada',
          color: Colors.black,
        ),
        _buildStatCard(
          title: 'En Mantenimiento',
          value: stats.inMaintenance.toString(),
          total: 'equipos en servicio',
          color: Colors.red.shade600,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String total,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                total,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall!.color!.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({super.key});

  void _showAddResourceModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddResourceModal(controller: _controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Recursos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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
                context.go('/admin-resources/assign');
              },
              icon: const Icon(Icons.person_add_alt_1, color: Colors.indigo),
              label: const Text(
                'Asignar Recursos',
                style: TextStyle(color: Colors.indigo, fontSize: 16),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.indigo),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FutureBuilder<String>(
              future: _controller.getCurrentUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton.icon(
                  onPressed: () => _showAddResourceModal(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agregar recurso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5B96),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class AddResourceModal extends StatelessWidget {
  final ResourcesController controller;

  const AddResourceModal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.inventory_2, color: Colors.indigo),
          SizedBox(width: 10),
          Text('Agregar Nuevo Recurso'),
        ],
      ),
      content: const Text(
        'Selecciona el tipo de recurso que deseas registrar en el sistema:',
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.people_alt_outlined),
            label: const Text('Recurso Humano'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const Screen2()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen.shade50,
              foregroundColor: Colors.green.shade800,
              side: BorderSide(color: Colors.green.shade800),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.build_outlined),
            label: const Text('Recurso Material'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const Screen3()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade800,
              side: BorderSide(color: Colors.blue.shade800),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class SearchBar1 extends StatelessWidget {
  final ResourcesController controller;
  const SearchBar1({super.key, required this.controller});

  final List<String> stateFilterOptions = const [
    'Todos los estados',
    'Disponible',
    'Ocupado',
    'En Uso',
    'Parcialmente Disponible',
    'Mantenimiento',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color.fromARGB(248, 221, 217, 217)),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros y Búsqueda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.searchC,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              hintText:
                                  'Buscar recursos por nombre, rol, ubicación...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder<String>(
                    valueListenable: controller.selectedStateFilter,
                    builder: (context, currentValue, child) {
                      return DropdownButtonFormField<String>(
                        initialValue: currentValue,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: stateFilterOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeStateFilter(value);
                          }
                        },
                      );
                    },
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

class Selector1 extends StatelessWidget {
  final ResourcesController controller;
  const Selector1({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: controller.resourceType,
      builder: (context, currentType, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectorButton(
                context,
                icon: Icons.people_alt_outlined,
                label: 'Recursos Humanos',
                isSelected: currentType == 'Humanos',
                onPressed: () {
                  controller.changeResourceType('Humanos');
                },
              ),
              const SizedBox(width: 20),
              _buildSelectorButton(
                context,
                icon: Icons.build_outlined,
                label: 'Recursos Materiales',
                isSelected: currentType == 'Materiales',
                onPressed: () {
                  controller.changeResourceType('Materiales');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectorButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isSelected ? Colors.indigo : Colors.grey.shade600,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.indigo : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: isSelected
            ? Colors.indigo.withOpacity(0.05)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}

class ResourceList extends StatelessWidget {
  final ResourcesController controller;
  const ResourceList({super.key, required this.controller});

  void _openAssignDialog(BuildContext context, String resourceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AssignResourceDialog(
          controller: controller,
          resourceName: resourceName,
        );
      },
    );
  }

  Widget _buildTag(String state) {
    Color tagColor;
    Color textColor;
    switch (state) {
      case 'Disponible':
      case 'Parcialmente Disponible':
        tagColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Ocupado':
      case 'En Uso':
        tagColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Mantenimiento':
      case 'Pendiente':
        tagColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      default:
        tagColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHResourceCard(
    BuildContext context,
    HumanResources resource,
    VoidCallback onDelete,
  ) {
    double progress = (resource.totalUsage > 0)
        ? (resource.usage / resource.totalUsage).clamp(0.0, 1.0)
        : 0.0;

    final List<String> projects = (resource.projects.isNotEmpty)
        ? resource.projects
        : <String>['Sin proyectos asignados'];

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
            // Header
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xff253f8d), size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff253f8d),
                        ),
                      ),
                      Text(
                        resource.lab,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),

            // State + usage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTag(resource.state),
                Text(
                  '${resource.usage.toInt()}/${resource.totalUsage.toInt()}h',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Text(
              'Proyectos actuales:',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: projects
                  .map(
                    (t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.blue.shade50,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),

            const Text(
              'Utilización',
              style: TextStyle(color: Colors.black54, fontSize: 13),
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

            _buildInfoRow(
              'Tarifa por hora:',
              '\$${resource.hourlyTarif.toStringAsFixed(2)}',
            ),
            _buildInfoRow('Contacto:', resource.email),
            _buildInfoRow('Habilidades:', resource.habilities),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _openAssignDialog(context, resource.name);
                    },
                    child: const Text('Asignar recurso'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDelete,
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

  Widget _buildMResourceCard(
    BuildContext context,
    MaterialResource resource,
    VoidCallback onDelete,
  ) {
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
            // Header name / lab
            Row(
              children: [
                const Icon(Icons.build, color: Color(0xff253f8d), size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff253f8d),
                        ),
                      ),
                      Text(
                        resource.lab,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTag(resource.state),
                _buildTag('Condición: ${resource.condition}'),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              'Tarifa por hora:',
              '\$${resource.hourlyTarif.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Última Mant.:',
              '${resource.lastMaintenance.day}/${resource.lastMaintenance.month}/${resource.lastMaintenance.year}',
            ),
            _buildInfoRow(
              'Próxima Mant.:',
              '${resource.nextMaintenance.day}/${resource.nextMaintenance.month}/${resource.nextMaintenance.year}',
            ),
            _buildInfoRow('Especificaciones:', resource.specs),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _openAssignDialog(context, resource.name);
                    },
                    child: const Text('Asignar recurso'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDelete,
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

  Widget _buildResourceCard(BuildContext context, ResourcesModel resource) {
    final String resourceId = resource.id;
    if (resource is HumanResources) {
      return _buildHResourceCard(
        context,
        resource,
        () => controller.deleteResource(resourceId),
      );
    } else if (resource is MaterialResource) {
      return _buildMResourceCard(
        context,
        resource,
        () => controller.deleteResource(resourceId),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Stream<List<ResourcesModel>>>(
      valueListenable: controller.filteredResourcesStream,
      builder: (context, resourceStream, child) {
        return StreamBuilder<List<ResourcesModel>>(
          stream: resourceStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar recursos: ${snapshot.error}'),
              );
            }

            final resources = snapshot.data ?? [];

            if (resources.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text(
                    'No se encontraron recursos con los filtros aplicados.',
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: resources.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final resource = resources[index];
                return _buildResourceCard(context, resource);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourcesModel resource) {
    Color stateColor = Colors.grey;
    switch (resource.state) {
      case 'Disponible':
        stateColor = Colors.green.shade700;
        break;
      case 'Ocupado':
        stateColor = Colors.red.shade700;
        break;
      case 'Parcialmente Disponible':
        stateColor = Colors.orange.shade700;
        break;
      case 'En Uso':
        stateColor = Colors.blue.shade700;
        break;
      case 'Mantenimiento':
        stateColor = Colors.purple.shade700;
        break;
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(
            resource is HumanResources
                ? Icons.person_outline
                : Icons.build_outlined,
            color: Colors.indigo,
          ),
          title: Text(resource.name),
          subtitle: Text(resource.lab),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              resource.state,
              style: TextStyle(
                color: stateColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ver detalles de ${resource.name}')),
            );
          },
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}

// ** Pantallas de Creación (Screen2 para Recursos humanos) **
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final ResourcesController controller = _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
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
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Creación de recursos humanos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            'Creación de recursos humanos',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        const Text('Nombre'),
                        CustomTextField(
                          hintText: 'John Doe',
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
                          items: const [
                            DropdownMenuItem(
                              value: 'Disponible',
                              child: Text('Disponible'),
                            ),
                            DropdownMenuItem(
                              value: 'Ocupado',
                              child: Text('Ocupado'),
                            ),
                            DropdownMenuItem(
                              value: 'En Uso',
                              child: Text('En Uso'),
                            ),
                            DropdownMenuItem(
                              value: 'Parcialmente Disponible',
                              child: Text('Parcialmente Disponible'),
                            ),
                          ],
                          initialValue: controller.stateC,
                          onChanged: (value) =>
                              setState(() => controller.stateC = value),
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
                          items: const [
                            DropdownMenuItem(
                              value: 'Laboratorio de Suelos',
                              child: Text('Laboratorio de Suelos'),
                            ),
                            DropdownMenuItem(
                              value: 'Laboratorio de Materiales y ensayos',
                              child: Text(
                                'Laboratorio de Materiales y ensayos',
                              ),
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
                              child: Text(
                                'Laboratorio de Ciencia de los Materiales',
                              ),
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
                          onChanged: (value) =>
                              setState(() => controller.labC = value),
                          validator: (_) => controller.validateLab(),
                        ),
                        const Text('Tarifa horaria'),
                        CustomTextField(
                          hintText: '200\$',
                          controller: controller.tarifController,
                          validator: controller.validateTarif,
                        ),
                        const Text('Uso total (horas)'),
                        CustomTextField(
                          hintText: '10',
                          controller: controller.totalUsage,
                          validator: controller.validateTarif,
                        ),
                        const Text('Correo'),
                        CustomTextField(
                          hintText: 'jonhdoe@unimet.edu.ve',
                          controller: controller.email,
                          validator: controller.validateEmail,
                        ),
                        const Text('Habilidades'),
                        CustomTextField(
                          hintText: 'Diseño',
                          maxLines: 4,
                          controller: controller.habilities,
                          validator: controller.validateHabilities,
                        ),
                        const Text('Departamento'),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Selecciona un departamento',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Construccion y Desarrollo Sustentable',
                              child: Text(
                                'Construccion y Desarrollo Sustentable',
                              ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Creando recurso...')),
                          );

                          controller.createHResource(context);
                          controller.clearResourceForm();

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff253f8d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Crear',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ** Pantallas de Creación (Screen3 para Recursos materiales) **
class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class StateFilterDropdown extends StatelessWidget {
  final ResourcesController controller;

  const StateFilterDropdown({super.key, required this.controller});

  final List<String> availableStates = const [
    'Todos los estados',
    'Disponible',
    'Ocupado',
    'En Uso',
    'Parcialmente Disponible',
    'Mantenimiento',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: controller.selectedStateFilter,
      builder: (context, currentValue, child) {
        return DropdownButton<String>(
          value: currentValue,
          underline: Container(),
          items: availableStates.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.selectedStateFilter.value = newValue;
            }
          },
        );
      },
    );
  }
}

class _Screen3State extends State<Screen3> {
  final ResourcesController controller = _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
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
                      const SizedBox(width: 15),
                      const Text(
                        'Creación de recursos materiales',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text('Nombre'),
                  CustomTextField(
                    hintText: 'Microscopio Electrónico',
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
                    items: const [
                      DropdownMenuItem(
                        value: 'Disponible',
                        child: Text('Disponible'),
                      ),
                      DropdownMenuItem(
                        value: 'Ocupado',
                        child: Text('Ocupado'),
                      ),
                      DropdownMenuItem(value: 'En Uso', child: Text('En Uso')),
                      DropdownMenuItem(
                        value: 'Parcialmente Disponible',
                        child: Text('Parcialmente Disponible'),
                      ),
                      DropdownMenuItem(
                        value: 'Mantenimiento',
                        child: Text('Mantenimiento'),
                      ),
                    ],
                    initialValue: controller.stateC,
                    onChanged: (value) =>
                        setState(() => controller.stateC = value),
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
                    items: const [
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
                    onChanged: (value) =>
                        setState(() => controller.labC = value),
                    validator: (_) => controller.validateLab(),
                  ),
                  const Text('Tarifa horaria'),
                  CustomTextField(
                    hintText: '200\$',
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
                    items: const [
                      DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                      DropdownMenuItem(
                        value: 'Regular',
                        child: Text('Regular'),
                      ),
                      DropdownMenuItem(value: 'Malo', child: Text('Malo')),
                    ],
                    initialValue: controller.conditionC,
                    onChanged: (value) =>
                        setState(() => controller.conditionC = value),
                    validator: (_) => controller.validateCondition(),
                  ),
                  const Text('Ultimo mantenimiento'),
                  TextFormField(
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        initialDate: DateTime.now(),
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
                    hintText: 'Voltaje: 200 kV',
                    maxLines: 4,
                    controller: controller.specs,
                    validator: controller.validateSpecs,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Creando recurso...')),
                          );

                          if (widget.runtimeType == Screen2) {
                            await controller.createHResource(context);
                          } else if (widget.runtimeType == Screen3) {
                            await controller.createMResource(context);
                          }

                          controller.clearResourceForm();

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff253f8d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Crear',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

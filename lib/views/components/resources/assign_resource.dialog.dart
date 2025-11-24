import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/resources_controller.dart';
import 'package:prolab_unimet/views/resources_view.dart';

class AssignResourceDialog extends StatefulWidget {
  final ResourcesController controller;
  final String resourceName;

  const AssignResourceDialog({
    super.key,
    required this.controller,
    required this.resourceName,
  });

  @override
  State<AssignResourceDialog> createState() => _AssignResourceDialogState();
}

class _AssignResourceDialogState extends State<AssignResourceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedProject;
  String? _selectedPriority;
  final TextEditingController _usageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill resource in controller to reuse logic if needed
    widget.controller.resource = widget.resourceName;
  }

  @override
  void dispose() {
    _usageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un proyecto.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await widget.controller.assignProject(
        _selectedProject,
        widget.resourceName,
        _usageController.text,
        context,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Recurso asignado a "${_selectedProject!}" correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al asignar recurso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar recurso a proyecto'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recurso seleccionado',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.resourceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xff253f8d),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Proyecto *'),
                const SizedBox(height: 4),
                FutureBuilder<List<String>>(
                  future: widget.controller.nombreProyectos(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      );
                    }

                    if (!snap.hasData || snap.data!.isEmpty) {
                      return DropdownButtonFormField<String>(
                        items: const [],
                        onChanged: null,
                        decoration: InputDecoration(
                          hintText: 'No hay proyectos disponibles',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }

                    final List<String> nombres = snap.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedProject,
                      items: nombres
                          .map(
                            (nombre) => DropdownMenuItem<String>(
                              value: nombre,
                              child: Text(nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedProject = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Seleccionar proyecto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                const Text('Prioridad *'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'Media', child: Text('Media')),
                    DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPriority = value);
                    widget.controller.priority = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Seleccionar prioridad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (_) => widget.controller.validatePriority(),
                ),
                const SizedBox(height: 12),

                const Text('Horas asignadas *'),
                CustomTextField(
                  hintText: 'Ejemplo: 8',
                  controller: _usageController,
                  validator: widget.controller.validateTarif,
                ),

                const Text('Descripción de la asignación'),
                CustomTextField(
                  hintText:
                      'Describe el propósito y alcance de esta asignación...',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _onSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff253f8d),
          ),
          child: const Text('Asignar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

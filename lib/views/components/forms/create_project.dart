// lib/views/projects/create_project.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prolab_unimet/models/projects_model.dart'; // where ProjectPriority lives
import 'package:prolab_unimet/widgets/app_dropdown.dart'; // reusable dropdown
import 'package:prolab_unimet/controllers/consulting_type_controller.dart'; // stream for consulting types

// UI-only DTO that the View returns to Controller
class ProjectCreateData {
  final String name;
  final String client;
  final String description;
  final String consultingType;
  final double budgetUsd;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime endDate;

  ProjectCreateData({
    required this.name,
    required this.client,
    required this.description,
    required this.consultingType,
    required this.budgetUsd,
    required this.priority,
    required this.startDate,
    required this.endDate,
  });
}

/// Pure UI dialog for creating a project.
/// No persistence, no controller calls — it only collects data and returns it.
class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  // --- Form state ---
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final _nameCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '15000');

  // --- Dropdowns & dates ---
  ProjectPriority? _priority;
  DateTime? _startDate;
  DateTime? _endDate;

  // Selected consulting type value from dropdown
  String? _selectedConsultingType;

  // Controller to get consulting types from Firestore
  final _ctController = ConsultingTypeController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // --- Small helpers (UI-only) ---
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? now.add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Seleccionar fecha';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Responsive width similar to your cards
    final dialogWidth = MediaQuery.of(context).size.width.clamp(360.0, 900.0);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Crear Proyecto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff253f8d),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa los datos del proyecto. Esta vista no guarda nada; solo devuelve el formulario.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  title: 'Información Básica',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _input(
                              label: 'Nombre del Proyecto *',
                              controller: _nameCtrl,
                              hint:
                                  'Ej: Análisis de Calidad del Agua – Empresa ABC',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\n')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _input(
                              label: 'Cliente *',
                              controller: _clientCtrl,
                              hint: 'Empresa o institución',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\n')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _input(
                        label: 'Descripción del Proyecto *',
                        controller: _descCtrl,
                        hint: 'Objetivos, alcance y metodología...',
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Mínimo 10 caracteres'
                            : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[\t\r]')),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ---------- Consulting Type dropdown fed by Firestore ----------
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tipo de Consultoría *',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                StreamBuilder<List<String>>(
                                  stream: _ctController
                                      .streamConsultingTypeNames(),
                                  builder: (context, snap) {
                                    // Loading state
                                    if (snap.connectionState ==
                                            ConnectionState.waiting &&
                                        !snap.hasData) {
                                      return const SizedBox(
                                        height: 52,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    // Error state with a minimal fallback
                                    if (snap.hasError) {
                                      return Text(
                                        'Error cargando tipos: ${snap.error}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      );
                                    }

                                    final items = (snap.data ?? [])
                                        .where((e) => e.trim().isNotEmpty)
                                        .toList();

                                    // If there are no items, show a disabled dropdown
                                    if (items.isEmpty) {
                                      return AppDropdown<String>(
                                        items: const [],
                                        value: null,
                                        labelOf: (x) => x,
                                        onChanged: null,
                                        hintText: 'No hay tipos de consultoría',
                                        validator: (_) =>
                                            'No hay opciones disponibles',
                                      );
                                    }

                                    // Keep selection if still present, otherwise null
                                    if (_selectedConsultingType != null &&
                                        !items.contains(
                                          _selectedConsultingType,
                                        )) {
                                      _selectedConsultingType = null;
                                    }

                                    return AppDropdown<String>(
                                      items: items,
                                      value: _selectedConsultingType,
                                      labelOf: (x) => x,
                                      hintText: 'Selecciona una opción',
                                      onChanged: (val) => setState(
                                        () => _selectedConsultingType = val,
                                      ),
                                      validator: (v) => v == null
                                          ? 'Selecciona el tipo de consultoría'
                                          : null,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _input(
                              label: 'Presupuesto (USD) *',
                              controller: _budgetCtrl,
                              hint: '15000',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: false,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final n = double.tryParse(
                                  v.replaceAll(',', '.'),
                                );
                                if (n == null || n <= 0) {
                                  return 'Monto inválido';
                                }
                                return null;
                              },
                              inputFormatters: [
                                // allow digits and one dot, up to 2 decimals
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}$'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _priorityDropdown()),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: 'Cronograma',
                  child: Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: 'Fecha de Inicio *',
                          valueText: _fmtDate(_startDate),
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dateField(
                          label: 'Fecha de Entrega *',
                          valueText: _fmtDate(_endDate),
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Crear Proyecto',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff253f8d),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final ok = _formKey.currentState?.validate() ?? false;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Corrige los errores del formulario',
                              ),
                            ),
                          );
                          return;
                        }
                        if (_priority == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona la prioridad'),
                            ),
                          );
                          return;
                        }
                        if (_startDate == null || _endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona fechas válidas'),
                            ),
                          );
                          return;
                        }
                        if (_endDate!.isBefore(_startDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La entrega no puede ser antes del inicio',
                              ),
                            ),
                          );
                          return;
                        }
                        if (_selectedConsultingType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selecciona el tipo de consultoría',
                              ),
                            ),
                          );
                          return;
                        }

                        final budget = double.parse(
                          _budgetCtrl.text.replaceAll(',', '.'),
                        );

                        Navigator.of(context).pop(
                          ProjectCreateData(
                            name: _nameCtrl.text.trim(),
                            client: _clientCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            consultingType: _selectedConsultingType!
                                .trim(), // dropdown value
                            budgetUsd: budget,
                            priority: _priority!,
                            startDate: _startDate!,
                            endDate: _endDate!,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI atoms (no business logic) ----------

  /// Section card with title and child content.
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xff253f8d),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// Reusable labeled text input.
  Widget _input({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Priority dropdown (enum -> human label).
  Widget _priorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<ProjectPriority>(
          value: _priority,
          items: const [
            DropdownMenuItem(value: ProjectPriority.low, child: Text('Baja')),
            DropdownMenuItem(
              value: ProjectPriority.medium,
              child: Text('Media'),
            ),
            DropdownMenuItem(value: ProjectPriority.high, child: Text('Alta')),
          ],
          onChanged: (v) => setState(() => _priority = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (v) => v == null ? 'Selecciona prioridad' : null,
        ),
      ],
    );
  }

  /// Fake input that opens a date picker.
  Widget _dateField({
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  valueText,
                  style: TextStyle(
                    color: valueText == 'Seleccionar fecha'
                        ? Colors.black45
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

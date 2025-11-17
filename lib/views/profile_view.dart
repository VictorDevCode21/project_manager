import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Tu AuthProvider personalizado
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/widgets/custom_text_field_widget.dart';
import 'package:prolab_unimet/controllers/profile_controller.dart';
import 'package:go_router/go_router.dart';
// CORRECCIÓN AQUÍ: Ocultamos 'AuthProvider' de Firebase para evitar el conflicto
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón de volver
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              onTap: () => context.go('/admin-dashboard'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Volver al dashboard',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Text(
            'Mi Perfil',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 28,
              color: Colors.indigo,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          // Gestor principal que carga los datos y muestra la UI
          const ProfileManager(),
        ],
      ),
    );
  }
}

class ProfileManager extends StatefulWidget {
  const ProfileManager({super.key});

  @override
  State<ProfileManager> createState() => _ProfileManagerState();
}

class _ProfileManagerState extends State<ProfileManager> {
  final ProfileController controller = ProfileController();
  late Future<String> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
  }

  Future<String> _loadUserData() async {
    try {
      // 1. Cargar datos de Firestore
      await controller.getName();

      // 2. Pre-llenar datos de Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        controller.newemailController.text = user!.email!;
        controller.oldemailController.text = user.email!;
      }
      return "Datos cargados";
    } catch (e) {
      return "Error";
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ahora Dart sabe que este AuthProvider es el tuyo (de prolab_unimet)
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<String>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Lógica de visualización del nombre
        String displayNombre = 'Usuario';

        if (controller.newnameController.text.isNotEmpty) {
          displayNombre = controller.newnameController.text;
        } else if (authProvider.name != null && authProvider.name!.isNotEmpty) {
          displayNombre = authProvider.name!;
          controller.newnameController.text = displayNombre;
        } else if (currentUser?.displayName != null) {
          displayNombre = currentUser!.displayName!;
        }

        final String displayEmail = currentUser?.email ?? 'Sin correo';
        final String displayRole = authProvider.role ?? 'MIEMBRO';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // TARJETA DE INFORMACIÓN
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.indigo.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xff253f8d).withOpacity(0.1),
                    child: Text(
                      displayNombre.isNotEmpty ? displayNombre[0].toUpperCase() : 'U',
                      style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xff253f8d),
                          fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayRole.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayNombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          displayEmail,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Separador
            Row(
              children: [
                const Icon(Icons.edit_note, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Editar Información',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 20),

            // ============================================================
            // FORMULARIO
            // ============================================================

            _buildLabel('Nombre completo'),
            CustomTextField(
              labelText: 'Nombre completo',
              controller: controller.newnameController,
              iconData: Icons.person_outline,
            ),

            const SizedBox(height: 15),

            _buildLabel('Número de teléfono'),
            CustomTextField(
              labelText: 'Número de teléfono',
              controller: controller.newphoneController,
              iconData: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 15),

            _buildLabel('Fecha de Nacimiento'),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: controller.selectedDate == null
                    ? ''
                    : '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    controller.selectedDate = picked;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Seleccionar fecha',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 164, 205, 191),
                    width: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Seguridad de la Cuenta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 15),

            _buildLabel('Correo Electrónico'),
            CustomTextField(
              labelText: 'correo@unimet.edu.ve',
              controller: controller.newemailController,
              iconData: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            _buildLabel('Contraseña Actual (Requerida para cambios)'),
            CustomTextField(
              labelText: 'Ingresa tu contraseña actual',
              controller: controller.oldpasswordController,
              obscureText: true,
              iconData: Icons.lock_outline,
            ),

            const SizedBox(height: 15),

            _buildLabel('Nueva Contraseña (Opcional)'),
            CustomTextField(
              labelText: 'Ingresa la nueva contraseña',
              controller: controller.newpasswordController,
              obscureText: true,
              iconData: Icons.lock_reset,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.modificarLogin(context);
                  setState(() {
                    _userDataFuture = _loadUserData();
                  });
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff253f8d),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
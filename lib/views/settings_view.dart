// lib/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos la instancia del AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // 2. Extraemos los datos del usuario con valores por defecto
    final String name = authProvider.name ?? 'Nombre de Usuario';
    final String email = authProvider.email ?? 'usuario@correo.unimet.edu.ve';
    final String role = authProvider.role ?? 'Sin Rol';

    return Scaffold(
      backgroundColor: Colors.transparent, // El fondo lo da el AdminLayout
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Para que la tarjeta se ajuste al contenido
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Usuario',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff253f8d), // Color principal
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo de Nombre
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Nombre Completo',
                    subtitle: name,
                  ),

                  const Divider(height: 20, thickness: 1),

                  // Campo de Correo
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Correo Institucional',
                    subtitle: email,
                  ),

                  const Divider(height: 20, thickness: 1),

                  // Campo de Rol
                  _buildInfoTile(
                    icon: Icons.shield_outlined,
                    title: 'Rol en el Sistema',
                    subtitle: role,
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Lógica futura para editar perfil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'La edición de perfil estará disponible próximamente.')),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar Perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
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

  /// Widget auxiliar para mostrar un campo de información
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade700, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
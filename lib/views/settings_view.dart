import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // --- WIDGETS AUXILIARES AHORA RECIBEN CONTEXT ---

  // Método auxiliar 1: Encabezado de Sección
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Método auxiliar 2: Tarjeta de Selección
  Widget _buildSelectionCard(
    BuildContext context, {
    required Widget contentIcon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),

          side: isSelected
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(4),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (color != null)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    contentIcon,

                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.deepPurple)
                  else if (color == null)
                    const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método auxiliar 3: Tarjeta de Tema
  Widget _buildThemeCard(
    BuildContext context,
    SettingsController controller,
    AppThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return _buildSelectionCard(
      context,
      contentIcon: Icon(icon),
      title: title,
      subtitle: subtitle,
      isSelected: controller.themeMode == mode,
      onTap: () => controller.setThemeMode(mode),
    );
  }

  // Método auxiliar 4: Tarjeta de Color
  Widget _buildColorCard(
    BuildContext context,
    SettingsController controller,
    AppColorScheme scheme,
    String title,
    String subtitleSuffix,
  ) {
    return _buildSelectionCard(
      context,
      contentIcon: const Icon(Icons.palette),
      title: title,
      subtitle: 'Esquema de colores ${title.toLowerCase()} $subtitleSuffix',
      isSelected: controller.colorScheme == scheme,
      onTap: () => controller.setColorScheme(scheme),
      color: controller.colorMap[scheme],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volver al Dashboard',
          style: TextStyle(fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin-dashboard');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Contenido de encabezado) ...
            const Text(
              'Configuración',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Personaliza la apariencia y configuración de la aplicación',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // --- Bloque: Tema de la Aplicación ---
            _buildSectionHeader(
              context,
              icon: Icons.settings,
              title: 'Tema de la Aplicación',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildThemeCard(
                  context,
                  controller,
                  AppThemeMode.light,
                  Icons.wb_sunny_outlined,
                  'Claro',
                  'Tema claro para uso diurno',
                ),
                _buildThemeCard(
                  context,
                  controller,
                  AppThemeMode.dark,
                  Icons.mode_night_outlined,
                  'Oscuro',
                  'Tema oscuro para uso nocturno',
                ),
                _buildThemeCard(
                  context,
                  controller,
                  AppThemeMode.system,
                  Icons.desktop_windows_outlined,
                  'Sistema',
                  'Sigue la configuración del sistema',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Bloque: Esquema de Colores ---
            _buildSectionHeader(
              context,
              icon: Icons.palette_outlined,
              title: 'Esquema de Colores',
            ),
            const SizedBox(height: 16),
            Text(
              'Elige el esquema de colores para personalizar la apariencia',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.blue,
                  'Azul',
                  '(predeterminado)',
                ),
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.green,
                  'Verde',
                  '',
                ),
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.purple,
                  'Morado',
                  '',
                ),
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.orange,
                  'Naranja',
                  '',
                ),
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.red,
                  'Rojo',
                  '',
                ),
                _buildColorCard(
                  context,
                  controller,
                  AppColorScheme.teal,
                  'Verde Azulado',
                  '',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Bloque: Configuraciones Adicionales ---
            _buildSectionHeader(
              context,
              icon: Icons.settings_applications_outlined,
              title: 'Configuraciones Adicionales',
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente: Notificaciones, idioma, y más opciones de personalización',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),

            Center(
              child: Icon(
                Icons.settings_outlined,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/views/layouts/admin_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminLayout extends StatefulWidget {
  bool isExpanded;
  final Widget
  child; // 👈 Aquí se mostrará el contenido dinámico debajo del navbar

  AdminLayout({super.key, required this.child, required this.isExpanded});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    // Necesitamos el AuthProvider para el logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    const Color navBarColor = Color(0xff253f8d);
    const Color iconColor = Colors.white70;
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Column(
        children: [
          // ===== NAVBAR SUPERIOR =====
          Container(
            height: 70,
            color: navBarColor, // Usamos la variable
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Logo e Identidad (SIN CAMBIOS)
                Row(
                  children: [
                    Image.asset('assets/Logo.png', height: 40, width: 40),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ProLab UNIMET',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Panel de Administrador',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 40),

                // Navegación (SIN CAMBIOS)
                const _NavButton(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: '/admin-dashboard',
                ),
                const SizedBox(width: 15),
                const _NavButton(
                  icon: Icons.folder_copy_outlined,
                  label: 'Proyectos',
                  route: '/admin-projects',
                ),

                const Spacer(),

                // ===== NAVEGACIÓN DERECHA (Notificaciones y Perfil) =====
                Row(
                  children: [
                    // Botón de Notificaciones (SIN CAMBIOS)
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: iconColor),
                      onPressed: () {
                        // TODO: Implementar lógica de notificaciones
                      },
                    ),
                    const SizedBox(width: 10),

                    // ===== AQUÍ ESTÁ EL CAMBIO =====
                    // Reemplazamos el CircleAvatar por un PopupMenuButton
                    PopupMenuButton<String>(
                      tooltip: 'Opciones de perfil',
                      color: navBarColor, // Fondo del menú igual al navbar
                      offset: const Offset(0, 55), // Ajusta la posición vertical
                      onSelected: (value) async {
                        // Lógica de navegación
                        switch (value) {
                          case 'settings':
                            context.go('/admin-settings');
                            break;
                          case 'logout':
                            await authProvider.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        // Opción 1: Ajustes
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: ListTile(
                            leading:
                            Icon(Icons.settings_outlined, color: iconColor),
                            title:
                            Text('Ajustes', style: TextStyle(color: textColor)),
                          ),
                        ),
                        // Opción 2: Cerrar Sesión
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: iconColor),
                            title: Text('Cerrar Sesión',
                                style: TextStyle(color: textColor)),
                          ),
                        ),
                      ],
                      // Este es el "child": el botón que se muestra (la "ranura")
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_outline, color: iconColor),
                      ),
                    ),
                    // ===== FIN DEL CAMBIO =====

                    const SizedBox(width: 10), // Espacio extra
                  ],
                ),
              ],
            ),
          ),

          // ===== CONTENIDO DEBAJO DEL NAVBAR (SIN CAMBIOS) =====
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _NavButton (SIN CAMBIOS)
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isActive = currentRoute == route;

    return TextButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(icon, color: isActive ? Colors.white : Colors.white70),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.white24 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
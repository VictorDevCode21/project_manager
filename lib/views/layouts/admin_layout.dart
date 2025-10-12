// lib/layouts/admin_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget
  child; // 👈 Aquí se mostrará el contenido dinámico debajo del navbar

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f7),
      body: Column(
        children: [
          // ===== NAVBAR SUPERIOR =====
          Container(
            height: 70,
            color: const Color(0xff253f8d),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Logo e Identidad
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
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Sistema de Gestión de Proyectos',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // ===== MENÚ DE NAVEGACIÓN =====
                _NavButton(
                  icon: Icons.home,
                  label: 'Inicio',
                  route: '/admin-dashboard',
                ),
                _NavButton(
                  icon: Icons.folder_outlined,
                  label: 'Proyectos',
                  route: '/admin-projects',
                ),
                _NavButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tareas',
                  route: '/admin-tasks',
                ),
                _NavButton(
                  icon: Icons.people_outline,
                  label: 'Recursos',
                  route: '/admin-resources',
                ),
                _NavButton(
                  icon: Icons.bar_chart_outlined,
                  label: 'Dashboard',
                  route: '/admin-dashboard',
                ),
                _NavButton(
                  icon: Icons.description_outlined,
                  label: 'Reportes',
                  route: '/admin-reports',
                ),
                const Spacer(),

                // Iconos a la derecha
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),

          // ===== CONTENIDO DEBAJO DEL NAVBAR =====
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

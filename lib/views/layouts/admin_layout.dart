// lib/layouts/admin_layout.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:prolab_unimet/controllers/settings_controller.dart';

String _formatTimeAgo(Timestamp timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp.toDate());

  if (difference.inMinutes < 1) return 'Hace segundos';
  if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
  if (difference.inDays < 1) return 'Hace ${difference.inHours} hrs';
  if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
  return 'Más de 1 sem';
}

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext buildContext) {
    final authProvider = Provider.of<AuthProvider>(buildContext, listen: false);
    final settingsController = Provider.of<SettingsController>(buildContext);
    final primaryColor =
        settingsController.colorMap[settingsController.colorScheme] ??
        const Color(0xff253f8d);

    const Color iconColor = Colors.white70;
    const Color textColor = Colors.white;

    return MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider.value(
          value: Provider.of<NotificationProvider>(buildContext),
        ),
        ChangeNotifierProvider.value(value: authProvider),
      ],

      child: Consumer2<NotificationProvider, AuthProvider>(
        builder: (context, notifProvider, auth, _) {
          final userRole = auth.role;
          final bool canViewResources =
              userRole == 'ADMIN' || userRole == 'COORDINATOR';

          if (notifProvider.toastNotification != null) {
            final notification = notifProvider.toastNotification!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        notification.body,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  //backgroundColor: navBarColor,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              notifProvider.clearToast();
            });
          }

          if (auth.newLoginUserName != null) {
            final name = auth.newLoginUserName;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Bienvenido de nuevo, $name!')),
              );
              auth.clearNewLoginUser();
            });
          }

          return Scaffold(
            //backgroundColor: const Color(0xfff4f6f7),
            body: Column(
              children: [
                // ===== NAVBAR =====
                Container(
                  height: 70,
                  color: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Logo
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

                      // ===== MENÚ DE NAVEGACIÓN =====
                      const _NavButton(
                        icon: Icons.home,
                        label: 'Inicio',
                        route: '/admin-homepage',
                      ),
                      const SizedBox(width: 15),
                      const _NavButton(
                        icon: Icons.folder_outlined,
                        label: 'Proyectos',
                        route: '/admin-projects',
                      ),
                      const SizedBox(width: 15),
                      const _NavButton(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tareas',
                        route: '/admin-tasks',
                      ),
                      const SizedBox(width: 15),

                      if (canViewResources)
                        const _NavButton(
                          icon: Icons.people_outline,
                          label: 'Recursos',
                          route: '/admin-resources',
                        ),

                      if (canViewResources) const SizedBox(width: 15),

                      const _NavButton(
                        icon: Icons.bar_chart_outlined,
                        label: 'Dashboard',
                        route: '/admin-dashboard',
                      ),
                      const SizedBox(width: 15),
                      const _NavButton(
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

                      PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'perfil',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline),
                                    SizedBox(width: 8),
                                    Text('Mi Perfil'),
                                  ],
                                ),
                              ),

                              const PopupMenuItem<String>(
                                value: 'configuracion',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings_outlined),
                                    SizedBox(width: 8),
                                    Text('Configuración'),
                                  ],
                                ),
                              ),

                              const PopupMenuDivider(),

                              const PopupMenuItem<String>(
                                value: 'ayuda',
                                child: Row(
                                  children: [
                                    Icon(Icons.description_outlined),
                                    SizedBox(width: 8),
                                    Text('Ayuda'),
                                  ],
                                ),
                              ),
                            ],

                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),

                        onSelected: (String result) {
                          switch (result) {
                            case 'perfil':
                              context.go('/admin-profile');
                              break;
                            case 'configuracion':
                              context.go('/admin-settings');
                              break;
                            case 'ayuda':
                              //context.go('/admin-help');
                              break;
                          }
                        },
                      ),

                      IconButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          await authProvider.logout();

                          if (context.mounted) {
                            context.go('/login');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesión cerrada correctamente'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // ===== CONTENIDO DEBAJO DEL NAVBAR =====
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
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
        },
        child: Container(), // El child debe estar vacío o ser un placeholder
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final BuildContext originalContext;

  const _NotificationBell({required this.originalContext});

  @override
  Widget build(BuildContext context) {
    const Color navBarColor = Color(0xff253f8d);
    const Color iconColor = Colors.white70;
    const Color textColor = Colors.white;

    final provider = Provider.of<NotificationProvider>(originalContext);
    final notifications = provider.notifications;
    final unreadCount = provider.unreadCount;

    return PopupMenuButton<String>(
      tooltip: 'Notificaciones',
      color: navBarColor,
      offset: const Offset(0, 55),

      onOpened: () {},

      onSelected: (value) {
        if (value == 'history') {
          GoRouter.of(context).go('/admin-notifications');
        } else {
          provider.markAsRead(value);
        }
      },

      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];

        if (provider.isLoading) {
          items.add(
            const PopupMenuItem(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        } else if (notifications.isEmpty) {
          items.add(
            const PopupMenuItem(
              enabled: false,
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: iconColor),
                title: Text(
                  'No hay notificaciones',
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
          );
        } else {
          items.addAll(
            notifications.map((notification) {
              final isUnread = !notification.isRead;
              return PopupMenuItem<String>(
                value: notification.id,
                child: ListTile(
                  leading: Icon(
                    isUnread ? Icons.notifications_active : Icons.notifications,
                    color: isUnread ? Colors.yellow.shade700 : iconColor,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    _formatTimeAgo(notification.createdAt),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }).toList(),
          );
        }

        items.add(
          PopupMenuItem<String>(
            value: 'history',
            child: ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.blue),
              title: Text(
                'Ver Historial Completo (${notifications.length})',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );

        return items;
      },
      child: Badge(
        label: Text(unreadCount.toString()),
        isLabelVisible: unreadCount > 0,
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.notifications_outlined, color: iconColor),
      ),
    );
  }
}

// lib/layouts/admin_layout.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/providers/notification_provider.dart';
import 'package:provider/provider.dart';

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
  final Widget
  child; // 👈 Aquí se mostrará el contenido dinámico debajo del navbar

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext buildContext) {
    final authProvider = Provider.of<AuthProvider>(buildContext, listen: false);
    const Color navBarColor = Color(0xff253f8d);
    const Color iconColor = Colors.white70;
    const Color textColor = Colors.white;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Provider.of<NotificationProvider>(buildContext),
        ),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: Consumer2<NotificationProvider, AuthProvider>(
        builder: (context, notifProvider, auth, layoutChild) {
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
                  backgroundColor: navBarColor,
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

          return layoutChild!;
        },
        child: Scaffold(
          backgroundColor: const Color(0xfff4f6f7),
          body: Column(
            children: [
              // ===== NAVBAR =====
              Container(
                height: 70,
                color: navBarColor,
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

                    // Botones del navbar
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
                    const SizedBox(width: 15),
                    const _NavButton(
                      icon: Icons.folder_copy_outlined,
                      label: 'Tareas',
                      route: '/admin-projects',
                    ),
                    const SizedBox(width: 15),
                    const _NavButton(
                      icon: Icons.folder_copy_outlined,
                      label: 'Recursos',
                      route: '/admin-projects',
                    ),
                    const SizedBox(width: 15),
                    const _NavButton(
                      icon: Icons.folder_copy_outlined,
                      label: 'Dashboard',
                      route: '/admin-projects',
                    ),
                    const SizedBox(width: 15),
                    const _NavButton(
                      icon: Icons.folder_copy_outlined,
                      label: 'Reportes',
                      route: '/admin-projects',
                    ),

                    const Spacer(),

                    // 🔔 Notificaciones + Perfil
                    _NotificationBell(originalContext: buildContext),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      tooltip: 'Opciones de perfil',
                      color: navBarColor,
                      offset: const Offset(0, 55),
                      onSelected: (value) async {
                        final messenger = ScaffoldMessenger.of(buildContext);
                        final router = GoRouter.of(buildContext);

                        switch (value) {
                          case 'settings':
                            router.go('/admin-settings');
                            break;
                          case 'profile':
                            router.go('/admin-profile');
                            break;
                          case 'logout':
                            await authProvider.logout();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Has cerrado sesión.'),
                              ),
                            );
                            router.go('/login');
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_circle,
                                color: iconColor,
                              ),
                              title: Text(
                                'Perfil',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListTile(
                              leading: Icon(
                                Icons.settings_outlined,
                                color: iconColor,
                              ),
                              title: Text(
                                'Ajustes',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListTile(
                              leading: Icon(Icons.logout, color: iconColor),
                              title: Text(
                                'Cerrar Sesión',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_outline, color: iconColor),
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
                      onPressed: () async {
                        final authProviderLocal = Provider.of<AuthProvider>(
                          buildContext,
                          listen: false,
                        );

                        await authProviderLocal.logout();

                        if (buildContext.mounted) {
                          GoRouter.of(buildContext).go('/login');
                          ScaffoldMessenger.of(buildContext).showSnackBar(
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
        ),
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

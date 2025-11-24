// lib/layouts/admin_layout.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/models/notification_model.dart';
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

    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notifProvider, auth, _) {
        // Toast notification
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
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
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

        // Welcome message
        if (auth.newLoginUserName != null) {
          final name = auth.newLoginUserName;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Bienvenido de nuevo, $name!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            auth.clearNewLoginUser();
          });
        }

        final String? role = auth.role; // 'ADMIN', 'COORDINATOR', 'USER'
        final bool isUserOnly = role == 'USER';

        return Scaffold(
          backgroundColor: const Color(0xfff4f6f7),
          body: Column(
            children: [
              // ================= NAVBAR =================
              Container(
                height: 70,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 900;
                    return Row(
                      children: [
                        // Logo
                        Flexible(
                          flex: isSmallScreen ? 2 : 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/Logo.png', height: 40, width: 40),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ProLab UNIMET',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (!isSmallScreen)
                                      Text(
                                        'Panel de Administrador',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isSmallScreen) const SizedBox(width: 40),

                        // ===== Navbar Buttons (role-based) =====
                        if (!isSmallScreen) ...[
                          Flexible(
                            child: const _NavButton(
                              icon: Icons.dashboard_outlined,
                              label: 'Dashboard',
                              route: '/admin-dashboard',
                            ),
                          ),
                          const SizedBox(width: 10),

                          if (!isUserOnly) ...[
                            Flexible(
                              child: const _NavButton(
                                icon: Icons.folder_copy_outlined,
                                label: 'Proyectos',
                                route: '/admin-projects',
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],

                          Flexible(
                            child: const _NavButton(
                              icon: Icons.folder_copy_outlined,
                              label: 'Tareas',
                              route: '/admin-tasks',
                            ),
                          ),

                          if (!isUserOnly) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: const _NavButton(
                                icon: Icons.folder_copy_outlined,
                                label: 'Recursos',
                                route: '/admin-resources',
                              ),
                            ),
                          ],

                          if (!isUserOnly) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: const _NavButton(
                                icon: Icons.folder_copy_outlined,
                                label: 'Reportes',
                                route: '/admin-reports',
                              ),
                            ),
                          ],
                        ],

                        const Spacer(),

                        // Notifications
                        const _NotificationBell(),
                        const SizedBox(width: 10),

                        // Profile menu
                        PopupMenuButton<String>(
                          tooltip: 'Opciones de perfil',
                          color: primaryColor,
                          offset: const Offset(0, 55),
                          onSelected: (value) async {
                            final messenger = ScaffoldMessenger.of(buildContext);
                            final router = GoRouter.of(buildContext);

                            switch (value) {
                              case 'profile':
                                router.go('/admin-profile');
                                break;
                              case 'settings':
                                router.go('/admin-settings');
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
                            // <<< CONFIGURACIÓN ENTRE PERFIL Y LOGOUT >>>
                            PopupMenuItem(
                              value: 'settings',
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ListTile(
                                  leading: Icon(Icons.settings, color: iconColor),
                                  title: Text(
                                    'Configuración',
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

                        // Extra logout icon (direct)
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
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                        ),

                        // Hamburger menu for small screens
                        if (isSmallScreen)
                          PopupMenuButton<String>(
                            tooltip: 'Menú',
                            color: primaryColor,
                            offset: const Offset(0, 55),
                            onSelected: (value) {
                              if (value.startsWith('/')) {
                                GoRouter.of(context).go(value);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: '/admin-dashboard',
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: ListTile(
                                    leading: Icon(Icons.dashboard_outlined, color: iconColor),
                                    title: Text('Dashboard', style: TextStyle(color: textColor)),
                                  ),
                                ),
                              ),
                              if (!isUserOnly)
                                PopupMenuItem(
                                  value: '/admin-projects',
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: ListTile(
                                      leading: Icon(Icons.folder_copy_outlined, color: iconColor),
                                      title: Text('Proyectos', style: TextStyle(color: textColor)),
                                    ),
                                  ),
                                ),
                              PopupMenuItem(
                                value: '/admin-tasks',
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: ListTile(
                                    leading: Icon(Icons.folder_copy_outlined, color: iconColor),
                                    title: Text('Tareas', style: TextStyle(color: textColor)),
                                  ),
                                ),
                              ),
                              if (!isUserOnly) ...[
                                PopupMenuItem(
                                  value: '/admin-resources',
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: ListTile(
                                      leading: Icon(Icons.folder_copy_outlined, color: iconColor),
                                      title: Text('Recursos', style: TextStyle(color: textColor)),
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: '/admin-reports',
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: ListTile(
                                      leading: Icon(Icons.folder_copy_outlined, color: iconColor),
                                      title: Text('Reportes', style: TextStyle(color: textColor)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                            child: const Icon(Icons.menu, color: Colors.white),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // ================= CONTENT =================
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
      },
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

    return Flexible(
      child: TextButton.icon(
        onPressed: () => context.go(route),
        icon: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 18),
        label: Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.white24 : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// =======================================================================
// Notification widgets
// =======================================================================

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final unreadCount = provider.unreadCount;

    return PopupMenuButton<String>(
      tooltip: 'Notificaciones',
      color: Colors.white,
      elevation: 5.0,
      offset: const Offset(0, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onSelected: (value) {
        if (value == 'history') {
          Navigator.of(context).pop();
          GoRouter.of(context).go('/admin-notifications');
        }
      },
      itemBuilder: (BuildContext popupContext) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _NotificationsPopover(
              provider: provider,
              parentContext: context,
            ),
          ),
        ];
      },
      child: Badge(
        label: Text(unreadCount.toString()),
        isLabelVisible: unreadCount > 0,
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.notifications_outlined, color: Colors.white70),
      ),
    );
  }
}

class _NotificationsPopover extends StatelessWidget {
  final NotificationProvider provider;
  final BuildContext parentContext;

  const _NotificationsPopover({
    required this.provider,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final notifications = provider.notifications;

    return Container(
      width: 360,
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notificaciones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Expanded(
            child: (provider.isLoading)
                ? const Center(child: CircularProgressIndicator())
                : (notifications.isEmpty)
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No hay notificaciones nuevas.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : Scrollbar(
                    child: ListView.separated(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationItemCard(
                          notification: notification,
                          provider: provider,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.black12),
                    ),
                  ),
          ),
          const Divider(height: 1, color: Colors.black12),
        ],
      ),
    );
  }
}

class _NotificationItemCard extends StatelessWidget {
  final NotificationModel notification;
  final NotificationProvider provider;

  const _NotificationItemCard({
    required this.notification,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInvitation = notification.type == 'project_invitation';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: notification.isRead ? Colors.white : const Color(0xFFF0F4FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  provider.dismissNotification(notification.id);
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.close, size: 18, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimeAgo(notification.createdAt),
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          if (isInvitation)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final bool success = await provider.acceptInvitation(
                        notification,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      if (!context.mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Has aceptado la invitación al proyecto.'
                                : 'No se pudo aceptar la invitación. Inténtalo de nuevo.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      provider.declineInvitation(notification);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// lib/layouts/admin_layout.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prolab_unimet/models/notification_model.dart'; // Make sure you import your model
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/providers/notification_provider.dart';
import 'package:provider/provider.dart';

// This function remains the same.
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
    // We get the authProvider here just for the profile menu,
    // but Consumer2 will handle the toast logic.
    final authProvider = Provider.of<AuthProvider>(buildContext, listen: false);
    const Color navBarColor = Color(0xff253f8d);
    const Color iconColor = Colors.white70;
    const Color textColor = Colors.white;

    // === 🚀 FIX START ===
    // We REMOVED the redundant MultiProvider.
    // We now start with Consumer2, which reads the providers
    // from main.dart.
    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notifProvider, auth, layoutChild) {
        // --- Toast/Snackbar logic (unchanged) ---
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
        // --- End of Toast logic ---

        // This returns the Scaffold (defined below in the 'child' property)
        return layoutChild!;
      },
      // The 'layoutChild' that Consumer2 receives is this Scaffold:
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
                  // Logo (remains the same)
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

                  // Navbar Buttons (remains the same)
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
                    route: '/admin-tasks',
                  ),
                  const SizedBox(width: 15),
                  const _NavButton(
                    icon: Icons.folder_copy_outlined,
                    label: 'Recursos',
                    route: '/admin-resources',
                  ),
                  const SizedBox(width: 15),
                  const _NavButton(
                    icon: Icons.folder_copy_outlined,
                    label: 'Reportes',
                    route: '/admin-reports',
                  ),

                  const Spacer(),

                  // 🔔 Notifications + Profile
                  const _NotificationBell(), // <-- Simplified

                  const SizedBox(width: 10),

                  // Profile Menu (remains the same)
                  PopupMenuButton<String>(
                    tooltip: 'Opciones de perfil',
                    color: navBarColor,
                    offset: const Offset(0, 55),
                    onSelected: (value) async {
                      // We use 'buildContext' here because it's from the original widget
                      final messenger = ScaffoldMessenger.of(buildContext);
                      final router = GoRouter.of(buildContext);

                      switch (value) {
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
                  // Logout Icon Button (remains the same)
                  IconButton(
                    onPressed: () async {
                      // We use 'buildContext' here as well
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

            // ===== CONTENT BELOW NAVBAR =====
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
    );
    // === 🚀 FIX END ===
  }
}

// Unchanged widget
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

// =======================================================================
// === 🚀 MODIFIED NOTIFICATION WIDGETS START HERE ===
// =======================================================================

///
/// This is the modified Notification Bell.
/// It no longer requires 'originalContext' because its own 'context'
/// can already see the providers from main.dart.
///
class _NotificationBell extends StatelessWidget {
  // const _NotificationBell({required this.originalContext}); // 👈 REMOVED
  const _NotificationBell(); // 👈 ADDED

  @override
  Widget build(BuildContext context) {
    // We can now safely use the widget's own 'context' to read the provider.
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
          // Close the popover first
          Navigator.of(context).pop();
          // Then navigate using the widget's 'context'
          GoRouter.of(context).go('/admin-notifications');
        }
      },
      itemBuilder: (BuildContext popupContext) {
        // We return a list with ONE item: our custom popover
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _NotificationsPopover(
              // Pass the provider we fetched above
              provider: provider,
              // Pass the widget's context for navigation from the footer
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

///
/// This is the custom popover widget.
/// It now uses 'parentContext' to navigate from the footer.
///
class _NotificationsPopover extends StatelessWidget {
  final NotificationProvider provider;
  final BuildContext parentContext; // The context from _NotificationBell

  const _NotificationsPopover({
    required this.provider,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    // 'provider' is passed in, so we don't need to read it here.
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
          // === Header ===
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

          // === Notification List ===
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

          // === Footer ===
          const Divider(height: 1, color: Colors.black12),
        ],
      ),
    );
  }
}

///
/// This widget represents a single notification card
/// (Unchanged from the version I gave you previously)
///
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
      color: notification.isRead
          ? Colors.white
          : const Color(0xFFF0F4FF), // Highlight unread
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Title and Dismiss Button ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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
              // Dismiss ('x') button
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

          // === Timestamp ===
          Text(
            _formatTimeAgo(notification.createdAt),
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),

          // === Action Buttons (Conditional) ===
          if (isInvitation)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  // Accept Button
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

                  // Decline Button
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
